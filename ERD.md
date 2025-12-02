erDiagram
    USER ||--o{ ORDER : places
    USER ||--o{ RESERVATION : makes
    USER }o--|| VOUCHER : has
    
    ORDER ||--|{ ORDER_ITEM : contains
    PRODUCT ||--|{ ORDER_ITEM : is_part_of
    
    BRANCH ||--o{ RESERVATION : is_for

    PRODUCT ||--o{ PRODUCT_RELATIONSHIP : has_relationship

    USER {
        string id
        string name
        string email
        string password_hash
        string phone_number
        string role
    }

    PRODUCT {
        string id
        string name
        string description
        float price
        string image_url
        string category
    }

    PRODUCT_RELATIONSHIP {
        string product_id_1
        string product_id_2
        string relationship_type
        float score
    }

    BRANCH {
        string id
        string name
        string address
        string opening_hours
    }

    ORDER {
        string id
        string user_id
        string voucher_id
        date order_date
        string status
        float total_price
    }

    ORDER_ITEM {
        string order_id
        string product_id
        int quantity
    }

    RESERVATION {
        string id
        string user_id
        string branch_id
        date reservation_date
        int number_of_people
        string status
    }

    VOUCHER {
        string id
        string user_id
        string code
        float discount_amount
        date expiry_date
        boolean is_used
    }
