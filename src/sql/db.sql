CREATE DATABASE nails;

-- users
CREATE TABLE public.users (
    id SERIAL PRIMARY KEY,
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'specialist', 'accountant')) DEFAULT 'specialist',
    login VARCHAR(100) UNIQUE,
    password TEXT,
    name VARCHAR(63) NOT NULL,
    surname VARCHAR(63) NOT NULL,
    patronymic VARCHAR(63),
    phone VARCHAR(15) UNIQUE NOT NULL, 
    is_confirmed_phone BOOLEAN DEFAULT false,
    email VARCHAR(100) UNIQUE NOT NULL,
    is_confirmed_email BOOLEAN DEFAULT false,
    inn VARCHAR(12) UNIQUE NOT NULL,
    is_banned BOOLEAN DEFAULT false,
    time_zone VARCHAR(6) NOT NULL CHECK (time_zone IN (
        'UTC+2', 'UTC+3', 'UTC+4', 'UTC+5', 'UTC+6', 
        'UTC+7', 'UTC+8', 'UTC+9', 'UTC+10', 'UTC+11', 'UTC+12'
    )) DEFAULT 'UTC+3',
    locale VARCHAR(2) NOT NULL CHECK (locale IN ('ru', 'en')) DEFAULT 'ru',
    bank_bik VARCHAR(9),
    bank_acc VARCHAR(25),
    birthdate DATE CHECK (birthdate < CURRENT_DATE),
    address_reg TEXT,
    passport JSONB,
    equipments JSONB,
    ycl_staff_id INTEGER,
    agent_percent NUMERIC(15,2) CHECK (agent_percent >= 0 AND agent_percent <= 100),
    speciality_id INTEGER,
    studio_id INTEGER,
    passport_main VARCHAR(255),
    passport_registration VARCHAR(255),
    photo_front VARCHAR(255),
    registration_status VARCHAR(63) NOT NULL CHECK (registration_status IN ('in the process of filling', 'under review', 'confirmed')) DEFAULT 'in the process of filling',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION update_users_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_users_updated_at
BEFORE UPDATE ON public.users
FOR EACH ROW
EXECUTE FUNCTION update_users_updated_at();

-- verification_codes

CREATE TABLE public.verification_codes (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    type VARCHAR(10) NOT NULL CHECK (type IN ('phone', 'email')),
    value VARCHAR(100) NOT NULL,
    code VARCHAR(4) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_used BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- information

CREATE TABLE public.information (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255),
    short_name VARCHAR(255),
    inn VARCHAR(12),
    ogrn VARCHAR(13),
    kpp VARCHAR(9),
    okved VARCHAR(10),

    director_fio VARCHAR(255), 
    director_position VARCHAR(255), 
    director_basis TEXT,

    authorized_person_fio VARCHAR(255), 
    authorized_person_position VARCHAR(255),
    authorized_person_basis TEXT,

    general_role VARCHAR(25) NOT NULL CHECK (general_role IN ('director', 'authorized_person')) DEFAULT 'director',

    legal_address TEXT,
    correspondence_address TEXT,
    contact_phone VARCHAR(20),
    accounting_phone VARCHAR(20),
    email VARCHAR(255),
    website VARCHAR(255),
    bank_acc VARCHAR(20),
    bank_bik VARCHAR(9), -- БИК
    bank_cor VARCHAR(20), -- Корреспондентский счет
    bank_name VARCHAR(255), -- Наименование банка
    company_card TEXT, -- Карточка предприятия
    inn_file TEXT, -- ИНН файл
    ustat TEXT, -- Устав
    stamp TEXT, -- Подпись
    power_of_attorney TEXT, -- Доверенность на исполнительного директора
    director_signature TEXT, -- Факсимиле генерального директора
    authorized_person_signature TEXT -- Факсимиле исполняющего обязанности

    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION update_information_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_information_updated_at
BEFORE UPDATE ON public.information
FOR EACH ROW
EXECUTE FUNCTION update_information_updated_at();

-- information_changes

CREATE TABLE public.information_changes (
    id SERIAL PRIMARY KEY,
    changed_field TEXT NOT NULL, 
    old_value TEXT,              
    new_value TEXT,
    changed_by_fio VARCHAR(255) NOT NULL,             
    changed_by_role VARCHAR(25) NOT NULL CHECK (changed_by_role IN ('director', 'authorized_person')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- cities

CREATE TABLE public.cities (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


CREATE OR REPLACE FUNCTION update_cities_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_cities_updated_at
BEFORE UPDATE ON public.cities
FOR EACH ROW
EXECUTE FUNCTION update_cities_updated_at();

-- studios

CREATE TABLE public.studios (
    id SERIAL PRIMARY KEY,
    city_id INTEGER, -- ссылка на город из таблицы public.cities
    name TEXT NOT NULL, -- краткий адрес

    general_full_address TEXT, -- полный адрес студии
    general_area VARCHAR(255), -- площадь 
    general_cadastral_number VARCHAR(255), -- кадастровый номер 
    general_contract_number VARCHAR(255), -- № договора
    general_contract_date DATE, -- дата
    general_registration TEXT, -- регистрационные данные
    general_rent_price_per_sqm VARCHAR(255), -- цена аренды

    general_owner_last_name VARCHAR(255), -- фамилия владельца
    general_owner_first_name VARCHAR(255), -- имя владельца
    general_owner_middle_name VARCHAR(255), -- отчество владельца
    general_owner_phone VARCHAR(255),  -- телефон владельца
    general_owner_email VARCHAR(255),  -- почта владельца
    
    general_coowner_available BOOLEAN DEFAULT FALSE, -- совладелец
    general_coowner_last_name VARCHAR(255), -- фамилия совладельца
    general_coowner_first_name VARCHAR(255),  -- имя совладельца
    general_coowner_middle_name VARCHAR(255), -- отчество совладельца
    general_coowner_phone VARCHAR(255),  -- телефон совладельца
    general_coowner_email VARCHAR(255),  -- почта совладельца

    general_work_schedule VARCHAR(255), -- режим работы
    general_work_schedule_weekdays VARCHAR(255), -- будни
    general_work_schedule_weekends VARCHAR(255), -- выходные
    general_wifi_password VARCHAR(255), -- пароль от Wi-Fi
    general_alarm_code VARCHAR(255), -- код сигналки
    general_lock_code VARCHAR(255), -- код от замка

    general_services_mani INTEGER, -- маникюр
    general_services_pedi INTEGER, -- педикюр
    general_services_brows INTEGER, -- брови

    general_sublease_available BOOLEAN DEFAULT FALSE, -- субаренда
    general_sublease_area VARCHAR(255), -- площадь субаренды
    general_sublease_activity_type VARCHAR(255), -- вид деятельности
    general_sublease_rent_price_per_sqm VARCHAR(255), -- цена аренды субаренды
    
    general_sublease_contact_last_name VARCHAR(255), -- фамилия субарендатора
    general_sublease_contact_first_name VARCHAR(255), -- имя субарендатора
    general_sublease_contact_middle_name VARCHAR(255), -- отчество субарендатора
    general_sublease_contact_phone VARCHAR(255),  -- телефон субарендатора
    general_sublease_contact_email VARCHAR(255), -- почта субарендатора
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_studios_city FOREIGN KEY (city_id) REFERENCES public.cities(id) ON DELETE RESTRICT
);

CREATE OR REPLACE FUNCTION update_studios_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_studios_updated_at
BEFORE UPDATE ON public.studios
FOR EACH ROW
EXECUTE FUNCTION update_studios_updated_at();


-- prices

CREATE TABLE public.prices (
    id SERIAL PRIMARY KEY,
    city_id INTEGER, -- ссылка на город из таблицы public.cities
    self_employed_data JSONB NOT NULL, -- для самозанятых
    clients_mani_data JSONB NOT NULL, -- для клиентов маникюр
    clients_pedi_data JSONB NOT NULL, -- для клиентов педикюр
    clients_mani_pedi_four_hands_data JSONB NOT NULL, -- для клиентов маникюр и педикюр в 4 руки
    clients_design_data JSONB NOT NULL, -- для клиентов дизайн
    clients_additional_nail_services_data JSONB NOT NULL, -- для клиентов дополнительные услуги ногтевого сервиса
    clients_brow_arch_data JSONB NOT NULL, -- для клиентов архитектура бровей
    clients_promo_data JSONB NOT NULL, -- для клиентов акции
    clients_model_data JSONB NOT NULL, -- для клиентов модели на маникюр
    clients_goods_data JSONB NOT NULL, -- для клиентов товары
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_prices_city FOREIGN KEY (city_id) REFERENCES public.cities(id) ON DELETE RESTRICT
);

CREATE OR REPLACE FUNCTION update_prices_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_prices_updated_at
BEFORE UPDATE ON public.prices
FOR EACH ROW
EXECUTE FUNCTION update_prices_updated_at();

-- motivation

CREATE TABLE public.motivation (
    id SERIAL PRIMARY KEY,
    allowance_data JSONB NOT NULL, 
    deduction_data JSONB NOT NULL,

    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION update_motivation_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_motivation_updated_at
BEFORE UPDATE ON public.motivation
FOR EACH ROW
EXECUTE FUNCTION update_motivation_updated_at();

-- specialities

CREATE TABLE public.specialities (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION update_specialities_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_specialities_updated_at
BEFORE UPDATE ON public.specialities
FOR EACH ROW
EXECUTE FUNCTION update_specialities_updated_at();

-- periodicity

CREATE TABLE public.periodicity (
    id SERIAL PRIMARY KEY,
    reporting_frequency VARCHAR(255) NOT NULL CHECK (reporting_frequency IN ('1week', '2week')) DEFAULT '2week',
    reporting_day_of_week VARCHAR(255) NOT NULL CHECK (reporting_day_of_week IN ('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday')) DEFAULT 'sunday',
    document_send_frequency VARCHAR(255) NOT NULL CHECK (document_send_frequency IN ('daily', 'weekly', 'monthly', 'quarterly', 'semiannually', 'annually')) DEFAULT 'monthly',
    document_send_email VARCHAR(255) NOT NULL,

    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION update_periodicity_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_periodicity_updated_at
BEFORE UPDATE ON public.periodicity
FOR EACH ROW
EXECUTE FUNCTION update_periodicity_updated_at();

-- termination_reasons

CREATE TABLE public.termination_reasons (
    id SERIAL PRIMARY KEY,
    speciality_id INTEGER,
    reason VARCHAR(255) NOT NULL, 
    description TEXT NOT NULL, 
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_termination_reason_speciality_id FOREIGN KEY (speciality_id) REFERENCES public.specialities(id) ON DELETE RESTRICT
);

CREATE OR REPLACE FUNCTION update_termination_reasons_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_termination_reasons_updated_at
BEFORE UPDATE ON public.termination_reasons
FOR EACH ROW
EXECUTE FUNCTION update_termination_reasons_updated_at();
