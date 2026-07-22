package com.saketh.moviereservationsystem.repository;

import com.saketh.moviereservationsystem.entity.Screen;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ScreenRepository extends JpaRepository<Screen,Long> {
}
