package app.memovo.api.security;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.core.MethodParameter;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.support.WebDataBinderFactory;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.method.support.ModelAndViewContainer;

/**
 * Resolves method parameters annotated with @CurrentUser
 * Extracts the ClerkUser from request attributes set by ClerkAuthenticationFilter
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

        ClerkUser user = (ClerkUser) request.getAttribute("clerk.user");
        
        if (user == null) {
            throw new UnauthorizedException("User not authenticated");
        }

        return user;
    }
}
