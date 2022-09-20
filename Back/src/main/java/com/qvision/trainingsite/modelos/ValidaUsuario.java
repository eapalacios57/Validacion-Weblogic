/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.qvision.trainingsite.modelos;

import com.qvision.trainingsite.clases.Usuarios;

/**
 *
 * @author Jorge
 */
public class ValidaUsuario {

    public boolean iniciaSesion(Usuarios unUsuario) {
        boolean iniciar = false;
        if (unUsuario.getNomUsu().equals("qmatic@qvision.com.co") && unUsuario.getPassUsu().equals("secret")) {
            iniciar = true;
        }
        return iniciar;
    }

}
