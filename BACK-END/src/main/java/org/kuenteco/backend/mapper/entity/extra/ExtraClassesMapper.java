package org.kuenteco.backend.mapper.entity.extra;

import org.kuenteco.backend.entity.master.extra.*;
import org.kuenteco.backend.entity.slave.extra.*;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface ExtraClassesMapper {
    // Mapeo automático para DescriptionPaymentHistory
    MasterDescriptionPaymentHistory map(
            SlaveDescriptionPaymentHistory source);

    // Mapeo automático para DescriptionTransaction
    MasterDescriptionTransaction map(
            SlaveDescriptionTransaction source);

    // Mapeo automático para ContentNotification
    MasterContentNotification map(
            SlaveContentNotification source);

    // Mapeo automático para DescriptionCategory
    MasterDescriptionCategory map(
            SlaveDescriptionCategory source);

    // Mapeo automático para PayMethodInfo
    MasterPayMethodInfo map(
            SlavePayMethodInfo source);
}