package com.saketh.moviereservationsystem.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(
        name = "seats",
        uniqueConstraints = @UniqueConstraint(columnNames = {"screen_id", "row_label", "seat_number"})
)
@Getter
@Setter
@NoArgsConstructor
public class Seat {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "screen_id", nullable = false)
    private Screen screen;

    @NotBlank
    @Column(name = "row_label", nullable = false, length = 10)
    private String rowLabel;

    @NotNull
    @Positive
    @Column(name = "seat_number", nullable = false)
    private Integer seatNumber;
}
