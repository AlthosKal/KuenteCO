package org.kuenteco.backend.enums;

import static org.junit.jupiter.api.Assertions.*;

import java.util.Arrays;
import java.util.List;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.EnumSource;

@DisplayName("StateDebt Enum Unit Tests")
class StateDebtTest {

    @Test
    @DisplayName("Should have all expected debt state values")
    void shouldHaveAllExpectedDebtStateValues() {
        // Given
        List<StateDebt> expectedStates = Arrays.asList(
            StateDebt.ACTIVE,
            StateDebt.PAID,
            StateDebt.DEFEATED,
            StateDebt.REFINANCED,
            StateDebt.IN_MORATIUM,
            StateDebt.CANCELLED
        );

        // When
        StateDebt[] actualStates = StateDebt.values();

        // Then
        assertEquals(6, actualStates.length);
        assertTrue(Arrays.asList(actualStates).containsAll(expectedStates));
    }

    @Test
    @DisplayName("Should convert string to StateDebt enum")
    void shouldConvertStringToStateDebtEnum() {
        // Given & When & Then
        assertEquals(StateDebt.ACTIVE, StateDebt.valueOf("ACTIVE"));
        assertEquals(StateDebt.PAID, StateDebt.valueOf("PAID"));
        assertEquals(StateDebt.DEFEATED, StateDebt.valueOf("DEFEATED"));
        assertEquals(StateDebt.REFINANCED, StateDebt.valueOf("REFINANCED"));
        assertEquals(StateDebt.IN_MORATIUM, StateDebt.valueOf("IN_MORATIUM"));
        assertEquals(StateDebt.CANCELLED, StateDebt.valueOf("CANCELLED"));
    }

    @Test
    @DisplayName("Should throw exception for invalid debt state string")
    void shouldThrowExceptionForInvalidDebtStateString() {
        // Given
        String invalidState = "INVALID_DEBT_STATE";

        // When & Then
        assertThrows(IllegalArgumentException.class, () -> {
            StateDebt.valueOf(invalidState);
        });
    }

    @ParameterizedTest
    @EnumSource(StateDebt.class)
    @DisplayName("Should have string representation for all debt states")
    void shouldHaveStringRepresentationForAllDebtStates(StateDebt state) {
        // When
        String stateName = state.name();

        // Then
        assertNotNull(stateName);
        assertFalse(stateName.isEmpty());
        assertTrue(stateName.matches("^[A-Z_]+$")); // Should be uppercase with underscores
    }

    @Test
    @DisplayName("Should maintain debt state enum order consistency")
    void shouldMaintainDebtStateEnumOrderConsistency() {
        // Given
        StateDebt[] states = StateDebt.values();

        // Then - Verify specific order
        assertEquals(StateDebt.ACTIVE, states[0]);
        assertEquals(StateDebt.PAID, states[1]);
        assertEquals(StateDebt.DEFEATED, states[2]);
        assertEquals(StateDebt.REFINANCED, states[3]);
        assertEquals(StateDebt.IN_MORATIUM, states[4]);
        assertEquals(StateDebt.CANCELLED, states[5]);
    }

    @Test
    @DisplayName("Should support debt state transition validation logic")
    void shouldSupportDebtStateTransitionValidationLogic() {
        // Valid transitions from ACTIVE
        assertTrue(isValidDebtTransition(StateDebt.ACTIVE, StateDebt.PAID));
        assertTrue(isValidDebtTransition(StateDebt.ACTIVE, StateDebt.DEFEATED));
        assertTrue(isValidDebtTransition(StateDebt.ACTIVE, StateDebt.REFINANCED));
        assertTrue(isValidDebtTransition(StateDebt.ACTIVE, StateDebt.IN_MORATIUM));
        assertTrue(isValidDebtTransition(StateDebt.ACTIVE, StateDebt.CANCELLED));
        
        // Valid transitions from DEFEATED (overdue)
        assertTrue(isValidDebtTransition(StateDebt.DEFEATED, StateDebt.PAID));
        assertTrue(isValidDebtTransition(StateDebt.DEFEATED, StateDebt.REFINANCED));
        assertTrue(isValidDebtTransition(StateDebt.DEFEATED, StateDebt.IN_MORATIUM));
        assertTrue(isValidDebtTransition(StateDebt.DEFEATED, StateDebt.CANCELLED));
        
        // Valid transitions from IN_MORATIUM
        assertTrue(isValidDebtTransition(StateDebt.IN_MORATIUM, StateDebt.PAID));
        assertTrue(isValidDebtTransition(StateDebt.IN_MORATIUM, StateDebt.ACTIVE));
        assertTrue(isValidDebtTransition(StateDebt.IN_MORATIUM, StateDebt.REFINANCED));
        assertTrue(isValidDebtTransition(StateDebt.IN_MORATIUM, StateDebt.CANCELLED));
        
        // Valid transitions from REFINANCED
        assertTrue(isValidDebtTransition(StateDebt.REFINANCED, StateDebt.ACTIVE));
        assertTrue(isValidDebtTransition(StateDebt.REFINANCED, StateDebt.CANCELLED));
        
        // Invalid transitions (final states)
        assertFalse(isValidDebtTransition(StateDebt.PAID, StateDebt.ACTIVE));
        assertFalse(isValidDebtTransition(StateDebt.PAID, StateDebt.DEFEATED));
        assertFalse(isValidDebtTransition(StateDebt.CANCELLED, StateDebt.ACTIVE));
        assertFalse(isValidDebtTransition(StateDebt.CANCELLED, StateDebt.PAID));
    }

    @Test
    @DisplayName("Should identify active debt states correctly")
    void shouldIdentifyActiveDebtStatesCorrectly() {
        // Active debt states (still owe money)
        assertTrue(isActiveDebtState(StateDebt.ACTIVE));
        assertTrue(isActiveDebtState(StateDebt.DEFEATED));
        assertTrue(isActiveDebtState(StateDebt.IN_MORATIUM));
        
        // Non-active debt states
        assertFalse(isActiveDebtState(StateDebt.PAID));
        assertFalse(isActiveDebtState(StateDebt.CANCELLED));
        assertFalse(isActiveDebtState(StateDebt.REFINANCED)); // Depends on business logic
    }

    @Test
    @DisplayName("Should identify final debt states correctly")
    void shouldIdentifyFinalDebtStatesCorrectly() {
        // Final states (no further transitions expected)
        assertTrue(isFinalDebtState(StateDebt.PAID));
        assertTrue(isFinalDebtState(StateDebt.CANCELLED));
        
        // Non-final states (transitions allowed)
        assertFalse(isFinalDebtState(StateDebt.ACTIVE));
        assertFalse(isFinalDebtState(StateDebt.DEFEATED));
        assertFalse(isFinalDebtState(StateDebt.IN_MORATIUM));
        assertFalse(isFinalDebtState(StateDebt.REFINANCED));
    }

    @Test
    @DisplayName("Should identify problematic debt states correctly")
    void shouldIdentifyProblematicDebtStatesCorrectly() {
        // Problematic states (require attention)
        assertTrue(isProblematicDebtState(StateDebt.DEFEATED));
        assertTrue(isProblematicDebtState(StateDebt.IN_MORATIUM));
        
        // Non-problematic states
        assertFalse(isProblematicDebtState(StateDebt.ACTIVE));
        assertFalse(isProblematicDebtState(StateDebt.PAID));
        assertFalse(isProblematicDebtState(StateDebt.REFINANCED));
        assertFalse(isProblematicDebtState(StateDebt.CANCELLED));
    }

    @Test
    @DisplayName("Should categorize debt states by business impact")
    void shouldCategorizeDebtStatesByBusinessImpact() {
        // Positive resolution states
        assertTrue(isPositiveResolutionState(StateDebt.PAID));
        assertTrue(isPositiveResolutionState(StateDebt.REFINANCED));
        assertFalse(isPositiveResolutionState(StateDebt.CANCELLED));
        assertFalse(isPositiveResolutionState(StateDebt.DEFEATED));
        
        // Negative states (bad for credit)
        assertTrue(isNegativeState(StateDebt.DEFEATED));
        assertTrue(isNegativeState(StateDebt.IN_MORATIUM));
        assertTrue(isNegativeState(StateDebt.CANCELLED));
        assertFalse(isNegativeState(StateDebt.ACTIVE));
        assertFalse(isNegativeState(StateDebt.PAID));
        
        // Neutral states
        assertTrue(isNeutralState(StateDebt.ACTIVE));
        assertFalse(isNeutralState(StateDebt.PAID));
        assertFalse(isNeutralState(StateDebt.DEFEATED));
    }

    @Test
    @DisplayName("Should support payment calculation logic")
    void shouldSupportPaymentCalculationLogic() {
        // States that require payment
        assertTrue(requiresPayment(StateDebt.ACTIVE));
        assertTrue(requiresPayment(StateDebt.DEFEATED));
        assertTrue(requiresPayment(StateDebt.IN_MORATIUM));
        
        // States that don't require payment
        assertFalse(requiresPayment(StateDebt.PAID));
        assertFalse(requiresPayment(StateDebt.CANCELLED));
        assertFalse(requiresPayment(StateDebt.REFINANCED)); // New debt created
    }

    @Test
    @DisplayName("Should support notification logic")
    void shouldSupportNotificationLogic() {
        // States that should trigger notifications
        assertTrue(shouldNotify(StateDebt.DEFEATED));
        assertTrue(shouldNotify(StateDebt.IN_MORATIUM));
        
        // States that might trigger notifications
        assertFalse(shouldNotify(StateDebt.ACTIVE)); // Depends on due date
        
        // States that shouldn't trigger notifications
        assertFalse(shouldNotify(StateDebt.PAID));
        assertFalse(shouldNotify(StateDebt.CANCELLED));
        assertFalse(shouldNotify(StateDebt.REFINANCED));
    }

    // Helper methods for business logic validation
    private boolean isValidDebtTransition(StateDebt from, StateDebt to) {
        switch (from) {
            case ACTIVE:
                return to != StateDebt.ACTIVE; // Can transition to any other state
            case DEFEATED:
                return to == StateDebt.PAID || to == StateDebt.REFINANCED || 
                       to == StateDebt.IN_MORATIUM || to == StateDebt.CANCELLED;
            case IN_MORATIUM:
                return to == StateDebt.PAID || to == StateDebt.ACTIVE || 
                       to == StateDebt.REFINANCED || to == StateDebt.CANCELLED;
            case REFINANCED:
                return to == StateDebt.ACTIVE || to == StateDebt.CANCELLED;
            case PAID:
            case CANCELLED:
                return false; // Final states - no transitions allowed
            default:
                return false;
        }
    }

    private boolean isActiveDebtState(StateDebt state) {
        return state == StateDebt.ACTIVE || state == StateDebt.DEFEATED || state == StateDebt.IN_MORATIUM;
    }

    private boolean isFinalDebtState(StateDebt state) {
        return state == StateDebt.PAID || state == StateDebt.CANCELLED;
    }

    private boolean isProblematicDebtState(StateDebt state) {
        return state == StateDebt.DEFEATED || state == StateDebt.IN_MORATIUM;
    }

    private boolean isPositiveResolutionState(StateDebt state) {
        return state == StateDebt.PAID || state == StateDebt.REFINANCED;
    }

    private boolean isNegativeState(StateDebt state) {
        return state == StateDebt.DEFEATED || state == StateDebt.IN_MORATIUM || state == StateDebt.CANCELLED;
    }

    private boolean isNeutralState(StateDebt state) {
        return state == StateDebt.ACTIVE;
    }

    private boolean requiresPayment(StateDebt state) {
        return isActiveDebtState(state);
    }

    private boolean shouldNotify(StateDebt state) {
        return isProblematicDebtState(state);
    }
}
