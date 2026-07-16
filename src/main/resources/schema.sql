CREATE TABLE IF NOT EXISTS users (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('ADMIN', 'REGULAR'))
);

CREATE TABLE IF NOT EXISTS movies (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    poster_url VARCHAR(500),
    duration_minutes INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS genres (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS movie_genre (
    movie_id BIGINT NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
    genre_id BIGINT NOT NULL REFERENCES genres(id) ON DELETE CASCADE,
    PRIMARY KEY (movie_id, genre_id)
);

CREATE TABLE IF NOT EXISTS screens (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    total_seats INTEGER NOT NULL
);

-- RESTRICT: seats can carry reservation history further down the chain.
CREATE TABLE IF NOT EXISTS seats (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    screen_id BIGINT NOT NULL REFERENCES screens(id) ON DELETE RESTRICT,
    row_label VARCHAR(10) NOT NULL,
    seat_number INTEGER NOT NULL,
    CONSTRAINT uq_seat_per_screen UNIQUE (screen_id, row_label, seat_number)
);

-- RESTRICT: a movie/screen with showtimes shouldn't be deletable by accident.
CREATE TABLE IF NOT EXISTS showtimes (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    movie_id BIGINT NOT NULL REFERENCES movies(id) ON DELETE RESTRICT,
    screen_id BIGINT NOT NULL REFERENCES screens(id) ON DELETE RESTRICT,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    CONSTRAINT chk_showtime_valid_range CHECK (end_time > start_time)
    -- Note: overlap prevention (no two showtimes on the same screen at
    -- conflicting times) is handled at the application layer, not here.
    -- See README for the Postgres EXCLUDE constraint as a future option.
);

-- RESTRICT: protects booking/revenue history from disappearing via cascade.
CREATE TABLE IF NOT EXISTS reservations (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    showtime_id BIGINT NOT NULL REFERENCES showtimes(id) ON DELETE RESTRICT,
    status VARCHAR(20) NOT NULL CHECK (status IN ('PENDING', 'CONFIRMED', 'CANCELLED', 'EXPIRED')),
    total_amount NUMERIC(10, 2) NOT NULL,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS reservation_seats (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    -- CASCADE: a ReservationSeat has no meaning without its parent Reservation.
    reservation_id BIGINT NOT NULL REFERENCES reservations(id) ON DELETE CASCADE,
    -- RESTRICT: protects reservation history if a seat is ever removed.
    seat_id BIGINT NOT NULL REFERENCES seats(id) ON DELETE RESTRICT,
    -- RESTRICT: consistent with reservations -> showtimes above.
    showtime_id BIGINT NOT NULL REFERENCES showtimes(id) ON DELETE RESTRICT,
    price_at_booking NUMERIC(10, 2) NOT NULL,
    -- The overbooking-prevention constraint: no two rows can claim the
    -- same seat for the same showtime.
    CONSTRAINT uq_seat_per_showtime UNIQUE (showtime_id, seat_id)
);

-- ============================================
-- Indexes
-- Postgres does NOT auto-index foreign key columns
-- (confirmed against official docs) so these are added explicitly.
-- ============================================

CREATE INDEX IF NOT EXISTS idx_seats_screen_id ON seats(screen_id);

CREATE INDEX IF NOT EXISTS idx_showtimes_movie_id ON showtimes(movie_id);
CREATE INDEX IF NOT EXISTS idx_showtimes_screen_id ON showtimes(screen_id);
CREATE INDEX IF NOT EXISTS idx_showtimes_start_time ON showtimes(start_time);

CREATE INDEX IF NOT EXISTS idx_reservations_user_id ON reservations(user_id);
CREATE INDEX IF NOT EXISTS idx_reservations_showtime_id ON reservations(showtime_id);

CREATE INDEX IF NOT EXISTS idx_reservation_seats_reservation_id ON reservation_seats(reservation_id);
CREATE INDEX IF NOT EXISTS idx_reservation_seats_seat_id ON reservation_seats(seat_id);