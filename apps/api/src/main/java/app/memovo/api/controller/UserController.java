package app.memovo.api.controller;

import app.memovo.api.application.UserService;
import app.memovo.api.controller.docs.UserApiDocs;
import app.memovo.api.controller.dto.UserRequest;
import app.memovo.api.controller.dto.UserResponse;
import app.memovo.api.controller.mapper.UserControllerMapper;
import app.memovo.api.domain.model.User;
import app.memovo.api.exception.UserNotFoundException;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/users")
@Tag(name = "Users", description = "User management operations")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @UserApiDocs.CreateUserOperation
    @PostMapping
    public ResponseEntity<UserResponse> createUser(@Valid @RequestBody UserRequest request) {
        User user = UserControllerMapper.toDomain(request);
        User createdUser = userService.createUser(user);
        return ResponseEntity.status(HttpStatus.CREATED).body(UserControllerMapper.toResponse(createdUser));
    }

    @UserApiDocs.GetUserOperation
    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> getUser(@PathVariable String id) {
        return userService.getUserById(id)
                .map(UserControllerMapper::toResponse)
                .map(ResponseEntity::ok)
                .orElseThrow(() -> new UserNotFoundException("User not found with id: " + id));
    }

    @UserApiDocs.UpdateUserOperation
    @PutMapping("/{id}")
    public ResponseEntity<UserResponse> updateUser(@PathVariable String id, @Valid @RequestBody UserRequest request) {
        User user = UserControllerMapper.toDomain(request);
        User updatedUser = userService.updateUser(id, user);
        return ResponseEntity.ok(UserControllerMapper.toResponse(updatedUser));
    }

    @UserApiDocs.DeleteUserOperation
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteUser(@PathVariable String id) {
        userService.deleteUser(id);
    }
}
