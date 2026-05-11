package com.cadence;

import java.sql.Connection;
import java.sql.SQLException;

import com.cadence.config.DatabaseConfig;

public class App 
{
    public static void main( String[] args )
    {
        try (Connection conn = DatabaseConfig.getDataSource().getConnection()){
            System.out.println("Conexão com o banco OK!");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
