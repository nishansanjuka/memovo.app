package app.memovo.api.application;

import app.memovo.api.domain.model.User;
import java.util.Optional;

public interface UserService {
    User createUser(User user);
    User updateUser(String id, User user);
    Optional<User> getUserById(String id);
    void deleteUser(String id);
}
