package org.kuenteco.backend.mapper.logic.budget;

import java.util.List;
import org.kuenteco.backend.dto.logic.budget.BudgetEnrollmentDTO;
import org.kuenteco.backend.entity.BudgetEnrollment;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface BudgetEnrollmentMapper {

    @Mapping(target = "userEmail", source = "user.email")
    @Mapping(target = "profileEmail", source = "profile.email")
    @Mapping(target = "budgetName", source = "budget.name")
    @Mapping(target = "budgetId", source = "budget.id")
    BudgetEnrollmentDTO toDTO(BudgetEnrollment budgetEnrollment);

    List<BudgetEnrollmentDTO> toDTOList(List<BudgetEnrollment> budgetEnrollments);
}
