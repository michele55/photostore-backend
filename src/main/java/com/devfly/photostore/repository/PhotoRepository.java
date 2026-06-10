package com.devfly.photostore.repository;

import com.devfly.photostore.entity.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PhotoRepository extends JpaRepository<Photo, Long> {

    Page<Photo> findByActiveTrue(Pageable pageable);

    Page<Photo> findByCategoryAndActiveTrue(String category, Pageable pageable);

    @Query("SELECT p FROM Photo p WHERE p.active = true AND " +
           "(LOWER(p.title) LIKE LOWER(CONCAT('%', :q, '%')) OR " +
           " LOWER(p.description) LIKE LOWER(CONCAT('%', :q, '%')) OR " +
           " LOWER(p.location) LIKE LOWER(CONCAT('%', :q, '%')))")
    Page<Photo> search(@Param("q") String query, Pageable pageable);

    @Modifying
    @Query("UPDATE Photo p SET p.viewCount = p.viewCount + 1 WHERE p.id = :id")
    void incrementViews(@Param("id") Long id);

    List<Photo> findTop8ByActiveTrueOrderByOrderCountDesc();
}

