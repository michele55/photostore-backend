package com.devfly.photostore.controller;

import com.devfly.photostore.dto.AuthDto;
import com.devfly.photostore.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "${app.frontend-url}")
public class AuthController {

    private final AuthService authService;

    /**
     * POST /api/auth/register
     * Body: { "email": "...", "password": "...", "fullName": "..." }
     */
    @PostMapping("/register")
    public ResponseEntity<AuthDto.AuthResponse> register(
            @Valid @RequestBody AuthDto.RegisterRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(authService.register(req));
    }

    /**
     * POST /api/auth/login
     * Body: { "email": "...", "password": "..." }
     * Returns JWT token
     */
    @PostMapping("/login")
    public ResponseEntity<AuthDto.AuthResponse> login(
            @Valid @RequestBody AuthDto.LoginRequest req) {
        return ResponseEntity.ok(authService.login(req));
    }

    /**
     * GET /api/auth/me
     * Ritorna info utente loggato (dal token)
     */
    @GetMapping("/me")
    public ResponseEntity<String> me(
            org.springframework.security.core.Authentication auth) {
        return ResponseEntity.ok(auth.getName());
    }
}

