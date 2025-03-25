package org.kuenteco.backend.enums;

public enum State {
    PENDING,    // Cuenta creada pero no verificada
    ACTIVE,     // Cuenta verificada y activa
    INACTIVE,   // Cuenta desactivada por admin/usuario
    SUSPENDED   // Cuenta suspendida por infracciones
}