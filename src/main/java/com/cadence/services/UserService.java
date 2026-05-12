package com.cadence.services;

import java.util.List;
import java.util.UUID;

import com.cadence.models.UserModel;
import com.cadence.repositories.UserRepository;

import at.favre.lib.crypto.bcrypt.BCrypt;

public class UserService {
    UserRepository userRepository = new UserRepository();

    public UserModel criarUsuario(String email, String username, String passwordHash){
        if (buscarPorEmail(email) == null) {
            String hashedPassword = BCrypt.withDefaults().hashToString(12, passwordHash.toCharArray());
            return userRepository.criarUsuario(email, username, hashedPassword);
        } else {
            throw new RuntimeException("Usuario ja cadastrado");
        }
    }

    public List<UserModel> buscarTodosOsUsuario(){
        return userRepository.buscarTodosOsUsuarios();
    }

    public UserModel buscarPorEmail(String email) {
        return userRepository.buscarPorEmail(email);
    }

    public UserModel buscarPorId(UUID id){
        return userRepository.buscarPorId(id);
    }

    public UserModel buscarPorNome(String username){
        return userRepository.buscarPorUsername(username);
    }

    public UserModel atualizarUsuario(UUID id, String email, String username, String passwordHash){
    UserModel user = buscarPorId(id);
        if (user == null) {
            throw new RuntimeException("Usuário não encontrado.");
        }
        String hashedPassword = null;
        if (passwordHash != null && !passwordHash.isEmpty()) {
            hashedPassword = BCrypt.withDefaults().hashToString(12, passwordHash.toCharArray());
        }
        return userRepository.autalizarUsuario(id, email, username, hashedPassword);
    }

    public void deletarUsuario(UUID id){
        userRepository.deletarUsuario(id);
    }
}
