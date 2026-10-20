<!--
Sync Impact Report
Version change: not established -> 1.0.0 (initial adoption)
Modified principles:
- Principle slot 1 -> I. Training-Only Educational Scope
- Principle slot 2 -> II. Authorization and User Isolation
- Principle slot 3 -> III. Offline-First Infrastructure
- Principle slot 4 -> IV. Layered Application Design
- Principle slot 5 -> V. Verifiable, Minimal Changes
Added sections: none; existing constraint and workflow sections were defined.
Removed sections: none.
Follow-up TODO: determine the original ratification date.
-->
# ContosoDashboard Constitution

## Core Principles

### I. Training-Only Educational Scope
ContosoDashboard MUST remain an educational demonstration and MUST NOT be represented as
production-ready software or production security guidance. Changes and documentation MUST
preserve this limitation and MUST identify mock authentication, sample data, and simplified
architecture as training-only where relevant.

### II. Authorization and User Isolation
Every protected page and operation MUST require authentication and enforce the applicable role,
ownership, or project-membership rules. Services that access user-specific data MUST scope reads
and writes to the requesting user's authorized records. Changes to access control MUST be checked
for both permitted and denied cases; mock authentication MUST NOT be described as production
identity management.

### III. Offline-First Infrastructure
The default training experience MUST run locally without cloud accounts or external service
dependencies. Infrastructure integrations MUST be isolated behind application interfaces and
dependency injection when introduced, so local implementations remain usable and future adapters
do not leak into business logic.

### IV. Layered Application Design
The application MUST retain clear responsibilities between Blazor pages, services, data access,
and models. Persistence MUST use the registered Entity Framework Core context and the configured
SQLite provider unless a feature specification explicitly changes that constraint. Data model or
relationship changes MUST account for database creation, seed data, and existing service behavior.

### V. Verifiable, Minimal Changes
Each change MUST trace to a stated requirement and have a verifiable acceptance check. Prefer
focused automated tests where the repository supports them; otherwise document and perform
targeted build or manual checks, including relevant authorization cases. Changes MUST avoid
unrelated refactoring and MUST preserve existing behavior outside their stated scope.

## Additional Constraints
The application targets .NET 9 and uses ASP.NET Core with Blazor Server, Entity Framework Core,
and SQLite as recorded in the project configuration. UI changes MUST follow the existing Bootstrap
and Bootstrap Icons conventions. Training workflows MUST remain local and use the seeded sample
data where applicable. No implementation or documentation may imply that the mock user-selection
login, local database, or current security controls are sufficient for production deployment.

## Development Workflow
Feature work MUST use the repository's Spec Kit artifacts: capture user needs in a specification,
resolve material ambiguities, define an implementation plan, and derive actionable tasks before
implementation. Plans and reviews MUST identify affected data, authorization boundaries, and
offline behavior. Before completion, run the narrowest relevant automated checks and a build; when
no automated test exists for the changed behavior, record the manual verification performed.

## Governance
This constitution governs feature specifications, plans, tasks, implementation, and review. A
change that conflicts with a principle MUST either be redesigned or be accompanied by an explicit
constitution amendment approved through the repository's normal review process. Every amendment
MUST state its rationale and impact, update the version and amendment date, and be checked against
the project documentation and implementation.

Versioning follows semantic versioning: MAJOR for incompatible governance changes, MINOR for new
principles or materially expanded requirements, and PATCH for clarifications that do not change
obligations. Reviews MUST verify applicable principles, especially training-only scope, user
isolation, and offline operation. Any exception MUST be documented and MUST NOT silently imply
production suitability.

**Version**: 1.0.0 | **Ratified**: TODO(RATIFICATION_DATE): original adoption date is unknown | **Last Amended**: 2026-10-20
