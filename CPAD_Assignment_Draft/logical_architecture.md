# Logical Architecture - E-Commerce App (Scoped)

## 1. Architectural Style

The system follows a layered architecture with strict separation of concerns:

1. Presentation Layer
2. Application Layer
3. Domain Layer
4. Infrastructure Layer
5. Data Layer

This follows the layered architecture guidance from Larman (logical architecture with cohesive layer responsibilities and downward dependency flow).

## 2. Layer Responsibilities

### 2.1 Presentation Layer (Flutter UI for Web and Mobile)

Responsibilities:
- Render screens:
  - Login Screen
  - Dashboard with search and product listing
  - Product Detail screen
- Handle user input and field-level validation (format checks)
- Manage UI state and navigation
- Trigger use-cases through application services

Key components:
- `LoginPage`, `DashboardPage`, `ProductDetailPage`
- `AuthViewModel`, `CatalogViewModel`

### 2.2 Application Layer (Use-Case Orchestration)

Responsibilities:
- Coordinate app use-cases and workflow
- Apply request-level validation and orchestration rules
- Expose APIs consumed by UI and REST controllers

Key use-cases:
- `LoginCustomer`
- `SearchProducts`
- `ViewProductDetails`

Key components:
- `AuthApplicationService`
- `CatalogApplicationService`

### 2.3 Domain Layer (Business Rules)

Responsibilities:
- Define business entities and core domain rules
- Keep business behavior independent of frameworks

Entities:
- `Customer`
- `Product`

Domain rules in scope:
- Customer account must be active for successful login
- Search matches product `name` and `description`
- Only active products are returned in dashboard/detail views

### 2.4 Infrastructure Layer (Technical Services)

Responsibilities:
- Implement repository interfaces and persistence adapters
- Provide security and cross-cutting concerns
- Handle SQL queries and API integration plumbing

Key components:
- `CustomerRepositoryImpl`
- `ProductRepositoryImpl`
- `PasswordHasher`
- `JwtTokenProvider` (or session token provider)

### 2.5 Data Layer (SQL Database)

Responsibilities:
- Persist normalized relational data
- Enforce key and integrity constraints

Tables in scope:
- `customers`
- `products`

## 3. Inter-layer Interaction

Dependency direction is strictly top-down:
- Presentation -> Application -> Domain -> Infrastructure -> Data

No reverse dependency is allowed.

Typical flow: Login
1. `LoginPage` submits email/password to `AuthApplicationService`
2. Service queries customer record via repository interface
3. Infrastructure verifies password hash
4. Domain rule validates account status
5. Service returns auth result/token to UI

Typical flow: Search and Detail
1. `DashboardPage` sends search keyword to `CatalogApplicationService`
2. Service retrieves active products matching keyword
3. UI displays product list
4. Selecting an item loads full data via `ViewProductDetails`

## 4. Separation of Concerns (Rubric Mapping)

- UI concerns are isolated in Presentation layer
- Use-case orchestration is isolated in Application layer
- Business logic is isolated in Domain layer
- Persistence and technical dependencies are isolated in Infrastructure/Data layers

This structure improves maintainability, testability, and platform portability for web + mobile clients.
