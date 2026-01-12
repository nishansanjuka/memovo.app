package app.memovo.api.controller.mapper;

import app.memovo.api.controller.dto.UserRequest;
import app.memovo.api.controller.dto.UserResponse;
import app.memovo.api.domain.model.User;

public class UserControllerMapper {

    public static User toDomain(UserRequest request) {
        if (request == null) return null;
        User user = new User();
        user.setId(request.id());
        user.setFirstName(request.firstName());
        user.setLastName(request.lastName());
        user.setEmail(request.email());
        return user;
    }

    public static UserResponse toResponse(User user) {
        if (user == null) return null;
        return new UserResponse(
            user.getId(),
            user.getFirstName(),
            user.getLastName(),
            user.getEmail(),
            user.getCreatedAt(),
            user.getUpdatedAt()
        );
    }
}
