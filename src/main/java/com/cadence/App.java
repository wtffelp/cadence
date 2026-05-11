package com.cadence;

import java.sql.Connection;
import java.sql.SQLException;

import com.cadence.config.DatabaseConfig;

import io.javalin.Javalin;

public class App {
    public static void main( String[] args ){
        Javalin javalin = Javalin.create(
            config -> {
                config.bundledPlugins.enableCors(cors -> {
                    cors.addRule(rule -> {
                        // rule.allowHost("https://cadence.vercel.app");
                        rule.anyHost();
                    });
                });
            }
        ).start(7000);
        javalin.get("/health", ctx -> ctx.result("OK"));
        try (Connection conn = DatabaseConfig.getDataSource().getConnection()){
            System.out.println("Conexão com o banco OK!");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
