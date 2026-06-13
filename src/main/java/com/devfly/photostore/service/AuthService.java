package com.devfly.photostore.service;

import com.devfly.photostore.config.JwtService;
import com.devfly.photostore.dto.AuthDto;
import com.devfly.photostore.entity.User;
import com.devfly.photostore.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {
    private static final Logger log = LoggerFactory.getLogger(AuthService.class);
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthService(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtService jwtService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    @Transactional
    public AuthDto.AuthResponse register(AuthDto.RegisterRequest req) {
        if (userRepository.existsByEmail(req.getEmail())) {
            throw new IllegalArgumentException("Email gia registrata: " + req.getEmail());
        }
        User user = new User();
        user.setEmail(req.getEmail().toLowerCase().trim());
        user.setPassword(passwordEncoder.encode(req.getPassword()));
        user.setFullName(req.getFullName());
        user.setPhone(req.getPhone());
        user.setRole(User.Role.CUSTOMER);
        userRepository.save(user);
        log.info("Nuovo utente registrato: {}", user.getEmail());
        String token = jwtService.generateToken(user.getEmail(), user.getRole().name());
        return new AuthDto.AuthResponse(token, user.getEmail(), user.getFullName(), user.getRole().name());
    }

    public AuthDto.AuthResponse login(AuthDto.LoginRequest req) {
        User user = userRepository.findByEmail(req.getEmail().toLowerCase().trim())
                .orElseThrow(() -> new IllegalArgumentException("Credenziali non valide"));
        if (!user.isActive()) throw new IllegalArgumentException("Account disabilitato.");
        if (!passwordEncoder.matches(req.getPassword(), user.getPassword()))
            throw new IllegalArgumentException("Credenziali non valide");
        String token = jwtService.generateToken(user.getEmail(), user.getRole().name());
        return new AuthDto.AuthResponse(token, user.getEmail(), user.getFullName(), user.getRole().name());
    }
}
