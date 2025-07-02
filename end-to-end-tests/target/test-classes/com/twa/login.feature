Feature: Prueba de login para el sistema AiProfileApp

  Background:
    * url 'http://172.26.0.3:8080/api/app/v1/auth'
    * def loginPayload =
      """
      {
        "nameOrEmail": "juan@ejemplo.com",
        "password": "contraseña123"
      }
      """

  Scenario: Login exitoso
    Given path 'login'
    And request loginPayload
    When method post
    Then status 200
    And match response.message == 'Login exitoso'
    And match response.data.token != null
