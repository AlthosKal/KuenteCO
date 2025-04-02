package org.kuenteco.backend.mapper.entity.extra;

import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface ExtraClassesMapper {
    // Mapeo automático para DescriptionPaymentHistory
    org.kuenteco.backend.entity.master.extra.DescriptionPaymentHistory map(
            org.kuenteco.backend.entity.slave.extra.DescriptionPaymentHistory source);

    // Mapeo automático para DescriptionTransaction
    org.kuenteco.backend.entity.master.extra.DescriptionTransaction map(
            org.kuenteco.backend.entity.slave.extra.DescriptionTransaction source);

    // Mapeo automático para ContentNotification
    org.kuenteco.backend.entity.master.extra.ContentNotification map(
            org.kuenteco.backend.entity.slave.extra.ContentNotification source);

    // Mapeo automático para DescriptionCategory
    org.kuenteco.backend.entity.master.extra.DescriptionCategory map(
            org.kuenteco.backend.entity.slave.extra.DescriptionCategory source);

    // Mapeo automático para PayMethodInfo
    org.kuenteco.backend.entity.master.extra.PayMethodInfo map(
            org.kuenteco.backend.entity.slave.extra.PayMethodInfo source);
}