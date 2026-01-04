package app.memovo.api.security;

import org.springframework.core.MethodParameter;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.support.WebDataBinderFactory;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.method.support.ModelAndViewContainer;

import io.jsonwebtoken.Claims;
import jakarta.servlet.http.HttpServletRequest;

/**
 * Resolves method parameters annotated with @CurrentUser Extracts the JWT
 * Claims from request attributes and builds a simplified User object
 */
@Component
public class CurrentUserArgumentResolver implements HandlerMethodArgumentResolver {

    @Override
    public boolean supportsParameter(MethodParameter parameter) {
        return parameter.hasParameterAnnotation(CurrentUser.class)
                && parameter.getParameterType().equals(ClerkUser.class);
    }

    @Override
    public Object resolveArgument(MethodParameter parameter, ModelAndViewContainer mavContainer,
            NativeWebRequest webRequest, WebDataBinderFactory binderFactory) {
        HttpServletRequest request = webRequest.getNativeRequest(HttpServletRequest.class);

        if (request == null) {
            throw new UnauthorizedException("Unable to retrieve request");
        }

        Claims claims = (Claims) request.getAttribute("clerk.claims");

        if (claims == null) {
            throw new UnauthorizedException("User not authenticated");
        }

        // Extract user information from claims and build User object
        String id = claims.getSubject();
        String email = (String) claims.get("email");

        return new ClerkUser(id, email);
    }
}
