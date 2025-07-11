package com.example.back_end.connector.config;

public enum KuentecoEndpoint {
    GET_TRANSACTIONS_SUMMARY("transaction", "get-transactions-summary"),
    GET_USER_TRANSACTIONS("transaction", "get-user-transactions"),
    GET_BUDGET_SUMMARY("budget", "get-budget-summary"),
    GET_BUDGET_COMPARISON("budget", "get-budget-comparison"),
    GET_USER_DEBTS("debt", "get-user-debts");

    private final String hostKey;
    private final String endpointKey;

    KuentecoEndpoint(String hostKey, String endpointKey) {
        this.hostKey = hostKey;
        this.endpointKey = endpointKey;
    }

    public String getHostKey() {
        return hostKey;
    }

    public String getEndpointKey() {
        return endpointKey;
    }
}

