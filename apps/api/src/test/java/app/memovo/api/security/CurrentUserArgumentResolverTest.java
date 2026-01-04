package app.memovo.api.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.core.MethodParameter;
import org.springframework.web.context.request.NativeWebRequest;

import io.jsonwebtoken.Claims;
import jakarta.servlet.http.HttpServletRequest;

@ExtendWith(MockitoExtension.class)
class CurrentUserArgumentResolverTest {

    @Mock
    private NativeWebRequest webRequest;

    @Mock
    private HttpServletRequest httpRequest;

    @Mock
    private MethodParameter parameter;

    @InjectMocks
    private CurrentUserArgumentResolver resolver;

    @SuppressWarnings({"rawtypes", "unchecked"})
    @Test
    void supportsParameter_shouldReturnTrueForCurrentUserAnnotationWithClerkUser() {
        when(parameter.hasParameterAnnotation(CurrentUser.class)).thenReturn(true);
        when(parameter.getParameterType()).thenReturn((Class) ClerkUser.class);

        boolean result = resolver.supportsParameter(parameter);

        assertThat(result).isTrue();
    }

    @Test
    void supportsParameter_shouldReturnFalseWithoutAnnotation() {
        when(parameter.hasParameterAnnotation(CurrentUser.class)).thenReturn(false);

        boolean result = resolver.supportsParameter(parameter);

        assertThat(result).isFalse();
    }

    @Test
    void resolveArgument_shouldBuildClerkUserFromClaims() throws Exception {
        when(webRequest.getNativeRequest(HttpServletRequest.class)).thenReturn(httpRequest);
        Claims claims = mock(Claims.class);
        when(claims.getSubject()).thenReturn("user_123");
        when(claims.get("email")).thenReturn("test@example.com");
        when(httpRequest.getAttribute("clerk.claims")).thenReturn(claims);

        ClerkUser result = (ClerkUser) resolver.resolveArgument(parameter, null, webRequest, null);

        assertThat(result.getId()).isEqualTo("user_123");
        assertThat(result.getEmail()).isEqualTo("test@example.com");
    }

    @Test
    void resolveArgument_shouldThrowWhenRequestIsNull() {
        when(webRequest.getNativeRequest(HttpServletRequest.class)).thenReturn(null);

        assertThatThrownBy(() -> resolver.resolveArgument(parameter, null, webRequest, null))
                .isInstanceOf(UnauthorizedException.class)
                .hasMessageContaining("Unable to retrieve request");
    }

    @Test
    void resolveArgument_shouldThrowWhenClaimsNotFound() {
        when(webRequest.getNativeRequest(HttpServletRequest.class)).thenReturn(httpRequest);
        when(httpRequest.getAttribute("clerk.claims")).thenReturn(null);

        assertThatThrownBy(() -> resolver.resolveArgument(parameter, null, webRequest, null))
                .isInstanceOf(UnauthorizedException.class)
                .hasMessageContaining("User not authenticated");
    }
}
