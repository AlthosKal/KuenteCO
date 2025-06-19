package org.kuenteco.backend.service.profile;

import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import org.kuenteco.backend.dto.auth.TokenResponseDTO;
import org.kuenteco.backend.dto.profile.LoginProfileDTO;
import org.kuenteco.backend.dto.profile.NewProfileDTO;
import org.kuenteco.backend.dto.profile.ProfileDetailDTO;
import org.kuenteco.backend.dto.profile.UpdateProfileDTO;
import org.kuenteco.backend.entity.Profile;

public interface ProfileService {
    TokenResponseDTO authenticate(LoginProfileDTO dto, HttpServletResponse response);

    Object getProfiles();

    void registerProfile(NewProfileDTO dto);

    void updateProfile(UpdateProfileDTO dto);

    void deleteProfile(Profile account);
}
