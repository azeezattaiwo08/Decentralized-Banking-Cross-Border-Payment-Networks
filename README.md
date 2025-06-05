# Decentralized Banking Cross-Border Payment Networks

A comprehensive blockchain-based system for managing cross-border payments between verified banking institutions using Clarity smart contracts.

## Overview

This system provides a decentralized infrastructure for cross-border payments with built-in compliance checking, exchange rate management, and settlement coordination. The platform ensures secure, transparent, and compliant international money transfers between verified banking institutions.

## Architecture

The system consists of five interconnected smart contracts:

### 1. Bank Verification Contract (`bank-verification.clar`)
- **Purpose**: Manages registration and verification of banking institutions
- **Key Features**:
    - Bank registration with SWIFT codes and country information
    - Multi-status verification system (Pending, Verified, Suspended)
    - Principal-to-bank mapping for access control
    - Only contract owner can verify banks

### 2. Exchange Rate Contract (`exchange-rate.clar`)
- **Purpose**: Manages currency exchange rates for accurate conversions
- **Key Features**:
    - Authorized rate provider system
    - Real-time exchange rate updates
    - Currency conversion calculations with precision (rate × 10000)
    - Support for multiple currency pairs

### 3. Compliance Checking Contract (`compliance-checking.clar`)
- **Purpose**: Validates payments against regulatory compliance rules
- **Key Features**:
    - Configurable daily and single transaction limits
    - Country and bank blocking capabilities
    - Daily transaction tracking per bank
    - Comprehensive compliance validation

### 4. Payment Processing Contract (`payment-processing.clar`)
- **Purpose**: Processes cross-border payments between verified banks
- **Key Features**:
    - Multi-status payment lifecycle (Pending, Processing, Completed, Failed)
    - Integration with all other contracts for validation
    - Currency conversion during payment processing
    - Detailed payment tracking and references

### 5. Settlement Coordination Contract (`settlement-coordination.clar`)
- **Purpose**: Coordinates final settlement of payments in batches
- **Key Features**:
    - Batch settlement processing
    - Payment aggregation by bank pairs
    - Settlement status tracking
    - Efficient bulk settlement operations

## Contract Interactions

\`\`\`
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│ Bank            │    │ Exchange Rate    │    │ Compliance          │
│ Verification    │    │ Contract         │    │ Checking            │
└─────────────────┘    └──────────────────┘    └─────────────────────┘
│                       │                        │
└───────────────────────┼────────────────────────┘
│
┌─────────────────────┐
│ Payment             │
│ Processing          │
└─────────────────────┘
│
┌─────────────────────┐
│ Settlement          │
│ Coordination        │
└─────────────────────┘
\`\`\`

## Key Features

### Security & Compliance
- **Bank Verification**: Only verified banks can participate in payments
- **Compliance Checking**: Automatic validation against regulatory rules
- **Transaction Limits**: Configurable daily and per-transaction limits
- **Blocking System**: Ability to block countries and banks for compliance

### Efficiency
- **Batch Settlement**: Efficient processing of multiple payments
- **Real-time Exchange Rates**: Accurate currency conversions
- **Status Tracking**: Complete payment lifecycle visibility

### Transparency
- **Immutable Records**: All transactions recorded on blockchain
- **Audit Trail**: Complete history of all operations
- **Public Verification**: Anyone can verify bank and payment status

## Usage Examples

### 1. Register and Verify a Bank
```clarity
;; Register bank
(contract-call? .bank-verification register-bank 
  "BANK001" 
  "International Bank" 
  "US" 
  "INTLUS33")

;; Verify bank (contract owner only)
(contract-call? .bank-verification verify-bank "BANK001")
