package app.memovo.api.domain.port;

import app.memovo.api.domain.model.User;
import java.util.Optional;

public interface UserRepository {
    User save(User user);
    Optional<User> findById(String id);
    void deleteById(String id);
}
