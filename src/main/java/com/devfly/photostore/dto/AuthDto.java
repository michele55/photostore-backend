package com.devfly.photostore.dto;

import jakarta.validation.constraints.*;

public class AuthDto {

    public static class RegisterRequest {
        @NotBlank @Email
        private String email;
        @NotBlank @Size(min = 8)
        private String password;
        @NotBlank
        private String fullName;
        private String phone;
        public String getEmail() { return email; }
        public String getPassword() { return password; }
        public String getFullName() { return fullName; }
        public String getPhone() { return phone; }
    }

    public static class LoginRequest {
        @NotBlank @Email
        private String email;
        @NotBlank
        private String password;
        public String getEmail() { return email; }
        public String getPassword() { return password; }
    }

    public static class AuthResponse {
        private String token;
        private String email;
        private String fullName;
        private String role;
        public AuthResponse(String token, String email, String fullName, String role) {
            this.token = token; this.email = email;
            this.fullName = fullName; this.role = role;
        }
        public String getToken() { return token; }
        public String getEmail() { return email; }
        public String getFullName() { return fullName; }
        public String getRole() { return role; }
    }
}
