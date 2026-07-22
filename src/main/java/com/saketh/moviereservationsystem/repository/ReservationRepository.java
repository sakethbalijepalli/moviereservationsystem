package com.saketh.moviereservationsystem.repository;

import com.saketh.moviereservationsystem.entity.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ReservationRepository extends JpaRepository<Reservation, Long> {

    List<Reservation> findByUserId(Long userId);

    @Modifying
    @Query("UPDATE Reservation r SET r.status = 'CONFIRMED' " +
            "WHERE r.id = :id AND r.status = 'PENDING' AND r.expiresAt > CURRENT_TIMESTAMP")
    int confirmIfStillValid(@Param("id") Long id);

    @Modifying
    @Query("UPDATE Reservation r SET r.status = 'EXPIRED' " +
            "WHERE r.status = 'PENDING' AND r.expiresAt < CURRENT_TIMESTAMP")
    int expireStalePending();
}