package org.kuenteco.backend.enums;

import static org.junit.jupiter.api.Assertions.*;

import java.util.Arrays;
import java.util.List;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.EnumSource;

@DisplayName("State Enum Unit Tests")
class StateTest {

    @Test
    @DisplayName("Should have all expected state values")
    void shouldHaveAllExpectedStateValues() {
        // Given
        List<State> expectedStates =
                Arrays.asList(
                        State.PENDING,
                        State.ACTIVE,
                        State.INACTIVE,
                        State.SUSPENDED,
                        State.CANCELLED);

        // When
        State[] actualStates = State.values();

        // Then
        assertEquals(5, actualStates.length);
        assertTrue(Arrays.asList(actualStates).containsAll(expectedStates));
    }

    @Test
    @DisplayName("Should convert string to State enum")
    void shouldConvertStringToStateEnum() {
        // Given & When & Then
        assertEquals(State.PENDING, State.valueOf("PENDING"));
        assertEquals(State.ACTIVE, State.valueOf("ACTIVE"));
        assertEquals(State.INACTIVE, State.valueOf("INACTIVE"));
        assertEquals(State.SUSPENDED, State.valueOf("SUSPENDED"));
        assertEquals(State.CANCELLED, State.valueOf("CANCELLED"));
    }

    @Test
    @DisplayName("Should throw exception for invalid state string")
    void shouldThrowExceptionForInvalidStateString() {
        // Given
        String invalidState = "INVALID_STATE";

        // When & Then
        assertThrows(
                IllegalArgumentException.class,
                () -> {
                    State.valueOf(invalidState);
                });
    }

    @ParameterizedTest
    @EnumSource(State.class)
    @DisplayName("Should have string representation for all states")
    void shouldHaveStringRepresentationForAllStates(State state) {
        // When
        String stateName = state.name();

        // Then
        assertNotNull(stateName);
        assertFalse(stateName.isEmpty());
        assertTrue(stateName.matches("^[A-Z_]+$")); // Should be uppercase with underscores
    }

    @Test
    @DisplayName("Should maintain enum order consistency")
    void shouldMaintainEnumOrderConsistency() {
        // Given
        State[] states = State.values();

        // Then - Verify specific order that might be important for business logic
        assertEquals(State.PENDING, states[0]);
        assertEquals(State.ACTIVE, states[1]);
        assertEquals(State.INACTIVE, states[2]);
        assertEquals(State.SUSPENDED, states[3]);
        assertEquals(State.CANCELLED, states[4]);
    }

    @Test
    @DisplayName("Should support state transition validation logic")
    void shouldSupportStateTransitionValidationLogic() {
        // This test demonstrates how State enum can be used in business logic

        // Valid transitions from PENDING
        assertTrue(isValidTransition(State.PENDING, State.ACTIVE));
        assertTrue(isValidTransition(State.PENDING, State.CANCELLED));

        // Valid transitions from ACTIVE
        assertTrue(isValidTransition(State.ACTIVE, State.INACTIVE));
        assertTrue(isValidTransition(State.ACTIVE, State.SUSPENDED));
        assertTrue(isValidTransition(State.ACTIVE, State.CANCELLED));

        // Valid transitions from INACTIVE
        assertTrue(isValidTransition(State.INACTIVE, State.ACTIVE));
        assertTrue(isValidTransition(State.INACTIVE, State.CANCELLED));

        // Valid transitions from SUSPENDED
        assertTrue(isValidTransition(State.SUSPENDED, State.ACTIVE));
        assertTrue(isValidTransition(State.SUSPENDED, State.CANCELLED));

        // Invalid transitions (once cancelled, cannot change)
        assertFalse(isValidTransition(State.CANCELLED, State.ACTIVE));
        assertFalse(isValidTransition(State.CANCELLED, State.INACTIVE));
        assertFalse(isValidTransition(State.CANCELLED, State.SUSPENDED));
        assertFalse(isValidTransition(State.CANCELLED, State.PENDING));
    }

    @Test
    @DisplayName("Should identify active states correctly")
    void shouldIdentifyActiveStatesCorrectly() {
        // Active operational states
        assertTrue(isOperationalState(State.ACTIVE));

        // Non-operational states
        assertFalse(isOperationalState(State.PENDING));
        assertFalse(isOperationalState(State.INACTIVE));
        assertFalse(isOperationalState(State.SUSPENDED));
        assertFalse(isOperationalState(State.CANCELLED));
    }

    @Test
    @DisplayName("Should identify final states correctly")
    void shouldIdentifyFinalStatesCorrectly() {
        // Final states (no further transitions allowed)
        assertTrue(isFinalState(State.CANCELLED));

        // Non-final states (transitions allowed)
        assertFalse(isFinalState(State.PENDING));
        assertFalse(isFinalState(State.ACTIVE));
        assertFalse(isFinalState(State.INACTIVE));
        assertFalse(isFinalState(State.SUSPENDED));
    }

    @Test
    @DisplayName("Should categorize states by business logic")
    void shouldCategorizeStatesByBusinessLogic() {
        // Initial states
        assertTrue(isInitialState(State.PENDING));
        assertFalse(isInitialState(State.ACTIVE));

        // Temporary states (can be resumed)
        assertTrue(isTemporaryState(State.INACTIVE));
        assertTrue(isTemporaryState(State.SUSPENDED));
        assertFalse(isTemporaryState(State.CANCELLED));
        assertFalse(isTemporaryState(State.ACTIVE));

        // Permanent states
        assertTrue(isPermanentState(State.CANCELLED));
        assertFalse(isPermanentState(State.SUSPENDED));
    }

    // Helper methods for business logic validation
    private boolean isValidTransition(State from, State to) {
        switch (from) {
            case PENDING:
                return to == State.ACTIVE || to == State.CANCELLED;
            case ACTIVE:
                return to == State.INACTIVE || to == State.SUSPENDED || to == State.CANCELLED;
            case INACTIVE:
                return to == State.ACTIVE || to == State.CANCELLED;
            case SUSPENDED:
                return to == State.ACTIVE || to == State.CANCELLED;
            case CANCELLED:
                return false; // No transitions allowed from CANCELLED
            default:
                return false;
        }
    }

    private boolean isOperationalState(State state) {
        return state == State.ACTIVE;
    }

    private boolean isFinalState(State state) {
        return state == State.CANCELLED;
    }

    private boolean isInitialState(State state) {
        return state == State.PENDING;
    }

    private boolean isTemporaryState(State state) {
        return state == State.INACTIVE || state == State.SUSPENDED;
    }

    private boolean isPermanentState(State state) {
        return state == State.CANCELLED;
    }
}
