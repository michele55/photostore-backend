package com.devfly.photostore.repository;

import com.devfly.photostore.entity.Order;
import com.devfly.photostore.entity.OrderStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {

    Optional<Order> findByOrderNumber(String orderNumber);

    Optional<Order> findByStripeSessionId(String sessionId);

    Optional<Order> findByStripePaymentIntentId(String paymentIntentId);

    Page<Order> findByCustomerEmailOrderByCreatedAtDesc(String email, Pageable pageable);

    Page<Order> findByStatusOrderByCreatedAtDesc(OrderStatus status, Pageable pageable);

    List<Order> findByStatusOrderByCreatedAtAsc(OrderStatus status);
}

