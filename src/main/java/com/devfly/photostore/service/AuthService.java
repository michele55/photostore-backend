package com.devfly.photostore.service;

import com.devfly.photostore.config.JwtService;
import com.devfly.photostore.dto.AuthDto;
import com.devfly.photostore.entity.User;
import com.devfly.photostore.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    // ─────────────────────────────────────────────────────────────────
    // REGISTRAZIONE
    // ─────────────────────────────────────────────────────────────────
    @Transactional
    public AuthDto.AuthResponse register(AuthDto.RegisterRequest req) {
        if (userRepository.existsByEmail(req.getEmail())) {
            throw new IllegalArgumentException("Email già registrata: " + req.getEmail());
        }

        User user = User.builder()
                .email(req.getEmail().toLowerCase().trim())
                .password(passwordEncoder.encode(req.getPassword()))
                .fullName(req.getFullName())
                .phone(req.getPhone())
                .role(User.Role.CUSTOMER)
                .build();

        userRepository.save(user);
        log.info("Nuovo utente registrato: {}", user.getEmail());

        String token = jwtService.generateToken(user.getEmail(), user.getRole().name());

        return AuthDto.AuthResponse.builder()
                .token(token)
                .email(user.getEmail())
                .fullName(user.getFullName())
                .role(user.getRole().name())
                .build();
    }

    // ─────────────────────────────────────────────────────────────────
    // LOGIN
    // ─────────────────────────────────────────────────────────────────
    public AuthDto.AuthResponse login(AuthDto.LoginRequest req) {
        User user = userRepository.findByEmail(req.getEmail().toLowerCase().trim())
                .orElseThrow(() -> new IllegalArgumentException("Credenziali non valide"));

        if (!user.isActive()) {
            throw new IllegalArgumentException("Account disabilitato. Contatta il supporto.");
        }

        if (!passwordEncoder.matches(req.getPassword(), user.getPassword())) {
            throw new IllegalArgumentException("Credenziali non valide");
        }

        String token = jwtService.generateToken(user.getEmail(), user.getRole().name());

        return AuthDto.AuthResponse.builder()
                .token(token)
                .email(user.getEmail())
                .fullName(user.getFullName())
                .role(user.getRole().name())
                .build();
    }
}

