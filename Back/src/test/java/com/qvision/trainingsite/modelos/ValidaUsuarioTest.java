/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.qvision.trainingsite.modelos;

import com.qvision.trainingsite.clases.Usuarios;
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
public class ValidaUsuarioTest {

    public ValidaUsuarioTest() {
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
     * Test of iniciaSesion method, of class ValidaUsuario.
     */
    @Test
    public void testIniciaSesion() {
        System.out.println("iniciaSesion");
        Usuarios unUsuario = new Usuarios();
        unUsuario.setNomUsu("qmatic@qvision.com.co");
        unUsuario.setPassUsu("secret");
        ValidaUsuario instance = new ValidaUsuario();
        boolean expResult = true;
        boolean result = instance.iniciaSesion(unUsuario);
        assertEquals(expResult, result);
    }

}
