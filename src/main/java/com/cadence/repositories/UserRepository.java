package com.cadence.repositories;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.jdbi.v3.core.Jdbi;

import com.cadence.config.DatabaseConfig;
import com.cadence.models.UserModel;

public class UserRepository {
    Jdbi jdbi = Jdbi.create(DatabaseConfig.getDataSource());
    public UserModel criarUsuario(String email, String username, String passwordHash){
        jdbi.withHandle(handle -> {
            return handle.createUpdate("INSERT INTO users (email, username, password_hash) VALUES (:email, :username, :passwordHash)")
            .bind("email", email)
            .bind("username", username)
            .bind("passwordHash", passwordHash)
            .execute();
        });
        UserModel userModel = buscarPorEmail(email);
        return userModel; 
    }

    public List<UserModel> buscarTodosOsUsuarios(){
        return jdbi.withHandle(handle -> {
            return handle.createQuery("SELECT * FROM users")
            .mapToBean(UserModel.class)
            .list();
        });
    }

    public UserModel buscarPorEmail(String email){
        UserModel user = jdbi.withHandle(handle -> {
            Optional<UserModel> result = handle.createQuery("SELECT * FROM users WHERE email = :email")
            .bind("email", email)
            .mapToBean(UserModel.class)
            .findOne();
            return result.orElse(null);
        });
        return user;
    }

    public UserModel buscarPorId(UUID id){
        UserModel user = jdbi.withHandle(handle -> {
            Optional <UserModel> result = handle.createQuery("SELECT * FROM users WHERE id = :id")
            .bind("id", id)
            .mapToBean(UserModel.class)
            .findOne();
            return result.orElse(null);
        });
        return user;
    }

    public UserModel buscarPorUsername(String username){
        UserModel user = jdbi.withHandle(handle -> {
            Optional<UserModel> result = handle.createQuery("SELECT * FROM users WHERE username = :username")
            .bind("username", username)
            .mapToBean(UserModel.class)
            .findFirst();
            return result.orElse(null);
        });
        return user;
    }
    public UserModel autalizarUsuario(UUID id, String email, String username, String passwordHash){
        if (passwordHash != null) {
            jdbi.withHandle(handle -> {
            return handle.createUpdate("UPDATE users SET email = :email, username = :username, password_hash = :passwordHash WHERE id = :id")
                .bind("email", email)
                .bind("username", username)
                .bind("password_hash", passwordHash)
                .bind("id", id)
                .execute();
            });
        } else {
        jdbi.withHandle(handle -> {
            return handle.createUpdate("UPDATE users SET email = :email, username = :username WHERE id = :id")
                .bind("email", email)
                .bind("username", username)
                .bind("id", id)
                .execute();
            });
        }
        return buscarPorId(id);
    }

    public void deletarUsuario(UUID id){
        jdbi.withHandle(handle -> {
            return handle.createUpdate("DELETE FROM users WHERE id = :id")
                .bind("id", id)
                .execute();
        });
    }
}