package org.kuenteco.backend.mapper;

import org.kuenteco.backend.dto.account.NewAccountDTO;
import org.kuenteco.backend.entity.Account;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;

import java.sql.Timestamp;
import java.time.LocalDateTime;

@Mapper(componentModel = "spring")
public interface NewAccountMapper {

    @Mapping(target = "user", ignore = true) // Se establecerá manualmente en el servicio
    @Mapping(target = "startDate", source = ".", qualifiedByName = "currentTimestamp")
    Account toAccount(NewAccountDTO newAccountDTO);

    @Named("currentTimestamp")
    default Timestamp mapCurrentTimestamp(NewAccountDTO source) {
        return Timestamp.valueOf(LocalDateTime.now());
    }
}