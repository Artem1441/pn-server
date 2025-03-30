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


-- studios
CREATE TABLE public.studios (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,         
    firm_id INTEGER NOT NULL,
    hour_rent_price NUMERIC(15,2) DEFAULT 0 CHECK (hour_rent_price >= 0),
    equipments JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_timestamp
BEFORE UPDATE ON public.studios
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

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
