package still88.backend.dto.share;

import lombok.Data;

@Data
public class CancelRequestDto {
    private int createUserId;
    private String requestUserNickname;
}
