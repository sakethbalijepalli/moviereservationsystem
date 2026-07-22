package com.saketh.moviereservationsystem.repository;

import com.saketh.moviereservationsystem.entity.ReservationSeat;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ReservationSeatRepository extends JpaRepository<ReservationSeat, Long> {

    @Query("SELECT rs.seat.id FROM ReservationSeat rs " +
            "WHERE rs.showtime.id = :showtimeId " +
            "AND (rs.reservation.status = 'CONFIRMED' " +
            "OR (rs.reservation.status = 'PENDING' AND rs.reservation.expiresAt > CURRENT_TIMESTAMP))")
    List<Long> findBookedSeatIdsForShowtime(@Param("showtimeId") Long showtimeId);
}