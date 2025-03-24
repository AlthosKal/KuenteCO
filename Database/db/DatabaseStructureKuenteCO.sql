CREATE TYPE state AS ENUM('active', 'inactive', 'suspended');
CREATE TYPE accountType  AS ENUM('personal', 'business');
CREATE TYPE stateInvestment AS ENUM('active', 'inactive', 'suspended', 'finalized', 'canceled');
CREATE TYPE stateDebt AS ENUM('active','paid', 'defeated', 'refinanced', 'in moratorium', 'canceled');

CREATE TYPE pay_method_info AS (
    method VARCHAR(50),
    details JSONB
);


CREATE TABLE IF NOT EXISTS  KuenteCOUser (
    id UUID DEFAULT gen_random_uuid(),
    CONSTRAINT PK_id_User PRIMARY KEY (id),
    email VARCHAR(50) NOT NULL ,
    password VARCHAR(160) NOT NULL ,
    registerDate TIMESTAMP DEFAULT now() NOT NULL,
    account state DEFAULT 'active'
);


CREATE TABLE IF NOT EXISTS Account (
    id SERIAL,
    CONSTRAINT PK_id_Account PRIMARY KEY (id),
    idUser UUID,
    name VARCHAR(30),
    type accountType DEFAULT 'individual',
    balance NUMERIC DEFAULT 0,
    currency VARCHAR(10),
    startDate TIMESTAMP DEFAULT now() NOT NULL,
    CONSTRAINT FK_Account_User FOREIGN KEY (idUser)
        REFERENCES KuenteCOUser (id)
        ON UPDATE RESTRICT
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Subscription (
    id SERIAL,
    CONSTRAINT PK_id_Subscription PRIMARY KEY (id),
    idAccount INTEGER,
    type VARCHAR(50) NOT NULL,
    startDate TIMESTAMP DEFAULT now() NOT NULL ,
    expirationDate TIMESTAMP NOT NULL,
    state state DEFAULT 'inactive',
    CONSTRAINT FK_Subscription_Account FOREIGN KEY (idAccount)
        REFERENCES Account (id)
        ON UPDATE RESTRICT
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS PaySubscription (
    id SERIAL,
    CONSTRAINT PK_id_PaySubscription PRIMARY KEY (id),
    idSubscription INTEGER,
    amount NUMERIC,
    payDate TIMESTAMP DEFAULT now() NOT NULL,
    payMethod pay_method_info,
    CONSTRAINT FK_PaySubscription_Subscription FOREIGN KEY (idSubscription)
        REFERENCES Subscription (id)
        ON UPDATE RESTRICT
        ON DELETE CASCADE
);
--DROP TABLE IF EXISTS paymethistory;

CREATE TABLE IF NOT EXISTS PaymentHistory (
    id SERIAL,
    CONSTRAINT PK_id_PaymentHistory PRIMARY KEY (id),
    idPaySubscription INTEGER,
    details JSONB,
    CONSTRAINT FK_PaymentHistory_PaySubscription FOREIGN KEY (idPaySubscription)
        REFERENCES PaySubscription (id)
        ON UPDATE RESTRICT
        ON DELETE CASCADE
);

--DROP TABLE IF EXISTS Budget;

CREATE TABLE IF NOT EXISTS Budget (
      id SERIAL,
    CONSTRAINT PK_id_Budget PRIMARY KEY (id),
    idAccount INTEGER,
    idCategory INTEGER,
    name VARCHAR(100),
    description VARCHAR(255),
    assignedAmount NUMERIC NOT NULL,
    startDate TIMESTAMP DEFAULT now() NOT NULL ,
    finishDate TIMESTAMP NOT NULL,
    state state DEFAULT 'active',
    CONSTRAINT FK_Budget_Account FOREIGN KEY (idAccount)
        REFERENCES Account (id)
        ON UPDATE RESTRICT
        ON DELETE CASCADE,
    CONSTRAINT FK_Budget_Category FOREIGN KEY (idCategory)
        REFERENCES Category (id)
        ON UPDATE RESTRICT
        ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS Category (
    id SERIAL,
    CONSTRAINT PK_idCategory PRIMARY KEY (id),
    idAccount INTEGER,
    name VARCHAR(50),
    description JSONB,
    assignedBudget NUMERIC,
    startDate TIMESTAMP DEFAULT now() NOT NULL,
    finishDate TIMESTAMP NOT NULL,
    state state DEFAULT 'active',
    CONSTRAINT FK_Category_Account FOREIGN KEY (idAccount)
        REFERENCES Account (id)
        ON UPDATE RESTRICT
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Transaction
(
    id SERIAL,
    CONSTRAINT PK_id_Transaction PRIMARY KEY (id),
    idAccount INTEGER,
    idCategory INTEGER,
    type VARCHAR(50),
    amount NUMERIC,
    transactionDate TIMESTAMP DEFAULT now() NOT NULL,
    description JSONB,
    CONSTRAINT FK_Transaction_Account FOREIGN KEY (idAccount)
        REFERENCES Account (id)
        ON UPDATE RESTRICT
        ON DELETE CASCADE,
    CONSTRAINT FK_Transaction_Category FOREIGN KEY (idCategory)
        REFERENCES Category (id)
        ON UPDATE RESTRICT
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Investment (
    id SERIAL,
    CONSTRAINT PK_id_Investment PRIMARY KEY (id),
    idAccount INTEGER,
    type VARCHAR(50),
    initialAmount NUMERIC,
    profitability NUMERIC,
    startDate TIMESTAMP DEFAULT now() NOT NULL,
    state stateInvestment DEFAULT 'active',
    CONSTRAINT FK_Investment_Account FOREIGN KEY (idAccount)
        REFERENCES Account (id)
        ON UPDATE RESTRICT
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Debt (
    id SERIAL,
    CONSTRAINT PK_id_Debt PRIMARY KEY (id),
    idAccount INTEGER,
    name VARCHAR(50),
    totalAmount NUMERIC,
    pendingAmount NUMERIC,
    startDate TIMESTAMP DEFAULT now() NOT NULL,
    expirationDate TIMESTAMP NOT NULL,
    state stateDebt DEFAULT 'active',
    CONSTRAINT FK_Debt_Account FOREIGN KEY (idAccount)
        REFERENCES Account (id)
        ON UPDATE RESTRICT
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Notification (
    id SERIAL,
    CONSTRAINT PK_id_Notification PRIMARY KEY (id),
    idAccount INTEGER,
    dateSend TIMESTAMP DEFAULT now() NOT NULL,
    content JSONB,
    CONSTRAINT FK_Notification_Account FOREIGN KEY (idAccount)
        REFERENCES Account (id)
        ON UPDATE RESTRICT
);

--DROP TABLE IF EXISTS exchangeRate;

CREATE TABLE IF NOT EXISTS exchangeRate (
    id SERIAL PRIMARY KEY,
    baseCurrency VARCHAR(10) NOT NULL,
    targetCurrency VARCHAR(10) NOT NULL,
    rate NUMERIC NOT NULL,
    lastUpdated TIMESTAMP DEFAULT now() NOT NULL,
    UNIQUE (baseCurrency, targetCurrency) -- Evita duplicados
);


CREATE TABLE IF NOT EXISTS exchange_rate_logs (
    id SERIAL PRIMARY KEY,
    log_message TEXT,
    log_timestamp TIMESTAMP DEFAULT now()
);