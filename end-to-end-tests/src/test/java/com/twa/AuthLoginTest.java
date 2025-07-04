package com.twa;

import com.intuit.karate.junit5.Karate;

class AuthLoginTest {

    @Karate.Test
    Karate testLogin() {
        return Karate.run("login").relativeTo(getClass());
    }
}
