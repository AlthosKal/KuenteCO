package org.kuenteco.backend.mapper.logic.debt;

import java.util.List;
import org.kuenteco.backend.dto.logic.debt.DebtEnrollmentDTO;
import org.kuenteco.backend.entity.DebtEnrollment;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface DebtEnrollmentMapper {

    @Mapping(target = "userEmail", source = "user.email")
    @Mapping(target = "profileEmail", source = "profile.email")
    @Mapping(target = "debtName", source = "debt.name")
    @Mapping(target = "debtId", source = "debt.id")
    DebtEnrollmentDTO toDTO(DebtEnrollment debtEnrollment);

    List<DebtEnrollmentDTO> toDTOList(List<DebtEnrollment> debtEnrollments);
}
