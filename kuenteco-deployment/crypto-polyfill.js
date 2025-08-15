// Polyfill para crypto.subtle en contextos no HTTPS
(function() {
    'use strict';
    
    // Si crypto.subtle ya existe, no hacer nada
    if (window.crypto && window.crypto.subtle) {
        return;
    }
    
    // Crear un objeto crypto básico si no existe
    if (!window.crypto) {
        window.crypto = {};
    }
    
    // Mock básico de crypto.subtle para evitar errores
    window.crypto.subtle = {
        generateKey: function() {
            console.warn('crypto.subtle.generateKey is not available in non-secure context. Using fallback.');
            return Promise.reject(new Error('crypto.subtle not available in non-secure context'));
        },
        
        encrypt: function() {
            console.warn('crypto.subtle.encrypt is not available in non-secure context. Using fallback.');
            return Promise.reject(new Error('crypto.subtle not available in non-secure context'));
        },
        
        decrypt: function() {
            console.warn('crypto.subtle.decrypt is not available in non-secure context. Using fallback.');
            return Promise.reject(new Error('crypto.subtle not available in non-secure context'));
        },
        
        sign: function() {
            console.warn('crypto.subtle.sign is not available in non-secure context. Using fallback.');
            return Promise.reject(new Error('crypto.subtle not available in non-secure context'));
        },
        
        verify: function() {
            console.warn('crypto.subtle.verify is not available in non-secure context. Using fallback.');
            return Promise.reject(new Error('crypto.subtle not available in non-secure context'));
        },
        
        digest: function() {
            console.warn('crypto.subtle.digest is not available in non-secure context. Using fallback.');
            return Promise.reject(new Error('crypto.subtle not available in non-secure context'));
        },
        
        importKey: function() {
            console.warn('crypto.subtle.importKey is not available in non-secure context. Using fallback.');
            return Promise.reject(new Error('crypto.subtle not available in non-secure context'));
        },
        
        exportKey: function() {
            console.warn('crypto.subtle.exportKey is not available in non-secure context. Using fallback.');
            return Promise.reject(new Error('crypto.subtle not available in non-secure context'));
        }
    };
    
    // Fallback para crypto.getRandomValues si es necesario
    if (!window.crypto.getRandomValues) {
        window.crypto.getRandomValues = function(array) {
            console.warn('Using fallback random number generator');
            for (let i = 0; i < array.length; i++) {
                array[i] = Math.floor(Math.random() * 256);
            }
            return array;
        };
    }
    
    console.log('Crypto polyfill loaded for non-secure context');
})();
