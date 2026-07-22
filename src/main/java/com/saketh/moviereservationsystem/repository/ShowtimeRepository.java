package com.saketh.moviereservationsystem.repository;

import com.saketh.moviereservationsystem.entity.Showtime;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.data.jpa.repository.Query;

import java.time.OffsetDateTime;
import java.util.List;

public interface ShowtimeRepository extends JpaRepository<Showtime, Long> {

    @Query("SELECT s FROM Showtime s WHERE s.screen.id = :screenId " +
            "AND s.startTime < :endTime AND s.endTime > :startTime")
    List<Showtime> findOverlappingShowtimes(
            @Param("screenId") Long screenId,
            @Param("startTime") OffsetDateTime startTime,
            @Param("endTime") OffsetDateTime endTime
    );
}