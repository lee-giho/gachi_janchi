package com.gachi_janchi.repository;

import com.gachi_janchi.dto.ReviewWithWriterDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface ReviewRepositoryCustom {
  Page<ReviewWithWriterDto> searchByRestaurantId(String restaurantId, Pageable pageable, boolean onlyImage, String sortType);
}
