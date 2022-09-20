/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.qvision.trainingsite.clases;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 *
 * @author Jorge
 */
public class UsuariosTest {
    
    public UsuariosTest() {
    }
    
    @BeforeClass
    public static void setUpClass() {
    }
    
    @AfterClass
    public static void tearDownClass() {
    }
    
    @Before
    public void setUp() {
    }
    
    @After
    public void tearDown() {
    }

    /**
     * Test of getNomUsu method, of class Usuarios.
     */
    @org.junit.Test
    public void testGetNomUsu() {
        System.out.println("getNomUsu");
        Usuarios instance = new Usuarios();
        String expResult = "";
        String result = instance.getNomUsu();
        assertEquals(expResult, result);        
    }

    /**
     * Test of setNomUsu method, of class Usuarios.
     */
    @org.junit.Test
    public void testSetNomUsu() {
        System.out.println("setNomUsu");
        String nomUsu = "qmatic@qvision.com.co";
        Usuarios instance = new Usuarios();
        instance.setNomUsu(nomUsu);        
    }

    /**
     * Test of getPassUsu method, of class Usuarios.
     */
    @org.junit.Test
    public void testGetPassUsu() {
        System.out.println("getPassUsu");
        Usuarios instance = new Usuarios();
        String expResult = "";
        String result = instance.getPassUsu();
        assertEquals(expResult, result);
    }

    /**
     * Test of setPassUsu method, of class Usuarios.
     */
    @org.junit.Test
    public void testSetPassUsu() {
        System.out.println("setPassUsu");
        String passUsu = "secret";
        Usuarios instance = new Usuarios();
        instance.setPassUsu(passUsu);        
    }
    
}
