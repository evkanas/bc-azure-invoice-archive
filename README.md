# bc-azure-invoice-archive

Portfolio project by Evaldas Jablonskas, Microsoft Dynamics 365 Business Central AL / NAV Developer.

A neutralized Microsoft Dynamics 365 Business Central AL portfolio sample for sending posted sales invoices by email and archiving invoice documents to Azure Blob Storage.

## Overview

This project demonstrates a Business Central AL extension that extends the posted sales invoice process with external document archiving.

The sample covers a practical business scenario where a posted sales invoice can be sent by email and a copy of the generated invoice document can be stored in Azure Blob Storage for later retrieval.

The archived invoice file name is stored on the posted sales invoice, allowing the invoice document to be downloaded from the external archive when needed.

## Main Features

* Send posted sales invoices by email.
* Archive generated invoice documents to Azure Blob Storage.
* Archive an invoice without sending it by email.
* Store the archived invoice file name on the posted sales invoice.
* Download the archived invoice document from the archive.
* Configure Azure Storage settings from Business Central setup.
* Use a neutralized AL structure suitable for portfolio demonstration.

## Functional Flow

```text
Posted Sales Invoice
        |
        |-- Send by email
        |
        |-- Generate invoice document
        |
        |-- Upload invoice document to Azure Blob Storage
        |
        |-- Store archived invoice file name on the posted invoice
```

Alternative flow:

```text
Posted Sales Invoice
        |
        |-- Archive invoice document to Azure Blob Storage without sending email
```

## Configuration

The extension uses setup fields for Azure Blob Storage integration.

Example setup fields:

```text
Use Invoice Archiving
Azure Storage Account
Azure Shared Key
Invoice Container
```

The Business Central email sending process depends on the standard Business Central email account and email scenario configuration.

## Azure Blob Storage

The sample expects an existing Azure Storage Account and a Blob container.

Example container names:

```text
invoices
sample-invoices
posted-sales-invoices
```

The archived invoice file name is stored in Business Central and later used to download the document from Azure Blob Storage.

## Example Actions

The extension includes actions similar to:

```text
Archive Invoice Without Email
Download Invoice from Archive
```

These actions demonstrate how posted sales invoices can be archived and retrieved from an external storage location.

## Security Notes

This repository does not include real Azure credentials, real customer data, real invoice documents, production storage account keys, or business-specific configuration.

Do not store the following information in source control:

```text
Azure Shared Key
Azure connection strings
Gmail App Passwords
SMTP passwords
Customer invoice PDFs
Real customer email addresses
Production company data
```

For real projects, credentials should be stored and managed securely according to the organization’s security policies.

## What Was Neutralized

The original business-specific implementation was neutralized for portfolio use.

Neutralized elements include:

* Company-specific names.
* Customer-specific references.
* Real invoice data.
* Real email addresses.
* Real Azure keys and secrets.
* Internal business logic not required for demonstrating the integration pattern.

## Technical Scope

This sample focuses on the AL implementation pattern for:

* Posted sales invoice extension.
* Invoice document generation and handling.
* Azure Blob Storage upload/download logic.
* Setup-based integration parameters.
* User actions for archiving and downloading invoice documents.

It is intended as a portfolio sample and not as a ready-to-install AppSource product.

## Requirements

* Microsoft Dynamics 365 Business Central.
* AL development environment.
* Azure Storage Account.
* Azure Blob container.
* Configured Business Central email account, if email sending is tested.
* Valid test data in a sandbox or development environment.

## Limitations

This repository is provided as a neutralized portfolio sample.

It may require adaptation before use in a real production environment, including:

* Secure credential management.
* Production-ready authentication model for Azure Storage.
* Error handling improvements.
* Permission set review.
* Tenant-specific configuration.
* Full testing with real Business Central email scenarios.
* Compliance review for document retention and data protection requirements.

## Repository Purpose

The purpose of this repository is to demonstrate practical Business Central AL development experience, including integration with external cloud storage and invoice document handling.

This project is part of a Business Central AL portfolio.
