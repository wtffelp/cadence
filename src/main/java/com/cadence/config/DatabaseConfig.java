package com.cadence.config;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

public class DatabaseConfig {
    private static HikariDataSource dataSource;
    public static Properties loadProperties() throws IOException{
        Properties props = new Properties();
        try (InputStream input = DatabaseConfig.class.getResourceAsStream("/application.properties")){
            if (input == null) {
                throw new IOException("Sorry, unable to find" + "/application.properties");
            }
            props.load(input);
        }
        return props;
    }

    public static HikariDataSource getDataSource(){
        if (dataSource == null) {
            try {
                Properties props = DatabaseConfig.loadProperties();
                HikariConfig config = new HikariConfig();
                config.setJdbcUrl(props.getProperty("db.url"));
                config.setUsername(props.getProperty("db.user"));
                config.setPassword(props.getProperty("db.password"));

                dataSource = new HikariDataSource(config);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return dataSource;        
    }
}