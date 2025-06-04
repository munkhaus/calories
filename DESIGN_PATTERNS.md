# Project Design Patterns

## Overall Architecture:
The project adheres to **Clean Architecture** principles, promoting a separation of concerns and enhancing maintainability and testability. The architecture is primarily divided into four layers:

1.  **Domain Layer:** This is the core of the application, containing the business logic.
    *   **Entities (Models):** Plain Dart objects representing the core data structures. These are immutable and created using the `freezed` package, ensuring data integrity and predictability.
    *   **Repository Interfaces (Contracts):** Abstract definitions for data operations. These interfaces dictate how data should be fetched or stored, decoupling the domain layer from specific data sources.
    *   **Use Cases (Interactors):** Encapsulate specific business operations or user interactions. They orchestrate calls to repository interfaces and contain the core application logic.

2.  **Application Layer:** This layer acts as a bridge between the Presentation Layer (UI) and the Domain Layer.
    *   **State Management:** The project uses **Riverpod** for state management. `StateNotifier` classes are typically used to manage the state of features or specific parts of the UI. These notifiers interact with use cases or services from the domain/infrastructure layers to perform actions and update the state.
    *   **Service Coordination:** It may contain application-specific services that coordinate tasks involving multiple domain services or repositories.

3.  **Infrastructure Layer:** This layer provides concrete implementations for the interfaces defined in the Domain Layer.
    *   **Data Transfer Objects (DTOs):** Similar to domain models, DTOs are also created using the `freezed` package. They are specifically designed to match the structure of external data sources (like APIs). DTOs include `fromJson` and `toJson` methods for serialization/deserialization and a `toDomain` method to convert them into domain models.
    *   **Data Source Implementations:** Concrete implementations of repository interfaces. This includes code for interacting with REST APIs, local databases (e.g., using `shared_preferences`), or other external services.
    *   **API Client Logic:** Code responsible for making HTTP requests, handling responses, and managing API keys or tokens.

4.  **Presentation Layer (UI):** This is the layer responsible for everything related to user interface and user interaction.
    *   **Widgets and Pages:** Flutter widgets are used to build the user interface. Pages represent different screens in the application.
    *   **UI Logic:** Handles user input, displays data from state management (Riverpod providers), and triggers actions in the application layer (e.g., calling methods on `StateNotifier`s).
    *   **Styling and Theming:** Uses a consistent set of layout constants (e.g., `KSizes` from `lib/core/constants/k_sizes.dart`) for margins, padding, font sizes, etc., ensuring a uniform look and feel.

## Other Important Patterns and Conventions:

*   **Feature-Driven Architecture:** The codebase is organized by features (e.g., `onboarding`, `food_database`, `activity`). Each feature module typically contains its own domain, application, infrastructure, and presentation sub-directories, making the codebase modular and easier to navigate.
*   **Dependency Injection (DI):** Riverpod is used extensively for DI. Providers are used to make services, notifiers, and other dependencies available throughout the widget tree or to other providers, promoting loose coupling.
*   **Immutability:** Enforced through the `freezed` package for domain models, DTOs, and state classes. This helps in creating more predictable and easier-to-debug applications.
*   **Result Type for Error Handling:** The `result_type` package is used, especially in the domain and infrastructure layers. Functions that can fail return a `Result` object (either `Success` or `Failure`), making error handling more explicit and robust.
*   **Naming Conventions:** The project follows specific naming conventions for files, directories, and classes across different layers (e.g., `I` prefix for interfaces, `_model.dart` suffix for model files, `_dto.dart` for DTO files, `_page.dart` for page files).
*   **Asynchronous Operations:** `Future`-based programming is standard for any I/O-bound operations (network requests, disk access).
*   **Testing Strategy:** A comprehensive testing strategy is in place, including:
    *   **Unit Tests:** For domain logic, application services, and infrastructure components.
    *   **Widget Tests:** For UI components in the presentation layer.
    *   (Potentially Integration Tests and Golden Tests as mentioned in documentation, though specific examples aren't immediately visible without deeper test file inspection).
    Test files generally mirror the source code structure.

This structured approach, based on Clean Architecture and well-defined patterns, aims to create a scalable, maintainable, and testable Flutter application.
