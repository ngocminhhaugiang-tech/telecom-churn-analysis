-- 1. Xóa bảng cũ nếu đã tồn tại để chạy lại không bị lỗi
DROP TABLE IF EXISTS telco_customer_cleaned CASCADE;

-- 2. Tạo bảng sạch 'telco_customer_cleaned' từ View tích hợp
CREATE TABLE telco_customer_cleaned AS
SELECT 
    -- CHUẨN HÓA THÔNG TIN KHÁCH HÀNG & NHÂN KHẨU HỌC
    customer_id,
    TRIM(gender) AS gender,
    age,
    TRIM(under_30) AS under_30,
    TRIM(senior_citizen) AS senior_citizen,
    TRIM(married) AS married,
    COALESCE(number_of_dependents, 0) AS number_of_dependents,
    
    -- CHUẨN HÓA VỊ TRÍ ĐỊA LÝ
    TRIM(country) AS country,
    TRIM(state) AS state,
    TRIM(city) AS city,
    zip_code,
    COALESCE(population_count, 0) AS population_count,
    latitude,
    longitude,
    
    -- CHUẨN HÓA DỊCH VỤ SỬ DỤNG
    tenure_in_months,
    -- Nếu không có chương trình khuyến mãi, chuyển thành 'No Offer'
    CASE 
        WHEN offer IS NULL OR TRIM(offer) = '' OR TRIM(offer) = 'None' THEN 'No Offer'
        ELSE TRIM(offer)
    END AS offer,
    TRIM(phone_service) AS phone_service,
    TRIM(internet_service) AS internet_service,
    -- CẬP NHẬT: Chuẩn hóa nhóm không dùng mạng thành 'No internet service'
    CASE 
        WHEN internet_type IS NULL OR TRIM(internet_type) = '' OR TRIM(internet_type) = 'None' OR TRIM(internet_type) = 'No' THEN 'No internet service'
        ELSE TRIM(internet_type)
    END AS internet_type,
    TRIM(contract) AS contract,
    TRIM(payment_method) AS payment_method,
    COALESCE(monthly_charge, 0) AS monthly_charge,
    COALESCE(total_revenue, 0) AS total_revenue,
    
    -- CHUẨN HÓA TRẠNG THÁI RỜI BỎ (CHURN)
    COALESCE(satisfaction_score, 3) AS satisfaction_score, 
    TRIM(customer_status) AS customer_status,
    TRIM(churn_label) AS churn_label,
    COALESCE(churn_value, 0) AS churn_value,
    
    -- Khách hàng ở lại thì ghi rõ 'Non-Churned' thay vì để trống (NULL)
    CASE 
        WHEN customer_status <> 'Churned' OR churn_category IS NULL OR TRIM(churn_category) = '' THEN 'Non-Churned'
        ELSE TRIM(churn_category)
    END AS churn_category,
    
    -- Khách hàng ở lại thì ghi rõ 'No Churn Reason'
    CASE 
        WHEN customer_status <> 'Churned' OR churn_reason IS NULL OR TRIM(churn_reason) = '' THEN 'No Churn Reason'
        ELSE TRIM(churn_reason)
    END AS churn_reason

FROM vw_churn_master;

-- 3. Tạo Khóa chính để tối ưu hóa truy vấn
ALTER TABLE telco_customer_cleaned ADD PRIMARY KEY (customer_id);
