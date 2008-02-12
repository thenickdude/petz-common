unit petzpaletteunit;

interface

uses windows, graphics, gr32, sysutils, math, classes;

type
  TPFPalType = (pfpPetz, pfpBabyz, pfpOddballz, pfpCatz1, pfpDogz1);
  TGamePalette = array[0..255] of longword;
  PGamepalette = ^tgamepalette;
  TByteSet = set of byte;

const
  petztransparentindex = 253;
  oddballztransparentindex = 225;

  palPetz: TGamePalette = (
    $000000, $000080, $008000, $008080, $800000, $800080,
    $808000, $C0C0C0, $C8D0D4, $808040, $DDE2E7, $D8DEE3,
    $D4DADF, $D0D6DB, $CCD2D7, $C7CED3, $C3CACF, $BFC6CB,
    $BBC2C7, $B6BEC3, $757575, $6F6F6F, $6A6A6A, $656565,
    $606060, $5B5B5B, $565656, $515151, $4C4C4C, $464646,
    $424242, $3A3A3A, $333333, $2C2C2C, $242424, $1D1D1D,
    $161616, $0E0E0E, $070707, $000000, $96C2DC, $90BBD5,
    $8AB5CF, $85AFC8, $7FA9C2, $7AA2BB, $749CB5, $6F96AE,
    $6990A8, $6389A2, $224187, $203D7F, $1E3977, $1C3570,
    $1A3168, $182D61, $162959, $142552, $12214A, $101D42,
    $1673B4, $136DAF, $1168AA, $0E63A5, $0C5EA1, $09589C,
    $075397, $044E93, $02498E, $004489, $B79EF0, $B299E9,
    $AD95E3, $A891DD, $A38DD6, $9E88D0, $9984CA, $9480C3,
    $8F7CBD, $8B77B7, $0129A8, $0128A4, $01279F, $01269B,
    $012597, $012492, $01238E, $01228A, $012185, $012081,
    $0C4A6B, $0B4465, $0B3E60, $0B395B, $0B3356, $0A2D51,
    $0A274C, $0A2247, $0A1C42, $09163C, $388AA6, $3785A2,
    $37819E, $377D9A, $367896, $367493, $36708F, $356B8B,
    $356787, $356284, $7D7062, $76695D, $706358, $695D53,
    $63574E, $5D5049, $564A44, $50443F, $4A3E3A, $433836,
    $738E9A, $708A96, $6D8793, $6B8490, $68818C, $667E89,
    $637B86, $617882, $5E757F, $5B717C, $57AB55, $47A13C,
    $179915, $368335, $1C7B30, $197910, $176227, $2B5E2F,
    $145C13, $114110, $C3612B, $E34638, $FF3B33, $CE4333,
    $D71A16, $B63C2E, $A91C16, $90422A, $772219, $531911,
    $FFF0D8, $FFE0AC, $FFD699, $FFCA82, $E8B675, $FFC068,
    $DC9651, $CE9C18, $B98B56, $A9891E, $A7EDEB, $90EBEA,
    $77CCD1, $00F4F7, $32E8ED, $0BC4C3, $34C3C3, $17A29F,
    $439F9F, $2E7A6E, $FFFFFF, $E7E4C0, $D5C6AC, $B1A7A7,
    $A8A0A0, $B6A074, $B19983, $B19983, $B09880, $B09880,
    $ACBEE2, $9093D5, $6E76D7, $6773B8, $73779F, $5D6AA2,
    $586489, $4D5798, $42456A, $313C5A, $8C9E72, $808000,
    $757A42, $808000, $607839, $635A3D, $475826, $2B4121,
    $303912, $FFFFFF, $FFFFFF, $D8F6F4, $C2D8E9, $595F2C,
    $C5F4D3, $9FD3C4, $1AC7FF, $9BB8B0, $77B1AF, $8E94A5,
    $8FA9AC, $14A0D7, $087FC6, $466ECA, $618E79, $4D7E99,
    $808080, $2A9B65, $16CB00, $396CA7, $0042FF, $426497,
    $2A6599, $6A34DD, $754429, $B56958, $846B42, $806450,
    $4A5975, $6A240A, $808080, $C8D0D4, $FFFFFF, $000000,
    $000000, $000000, $FFFFFF, $C8D0D4, $C8D0D4, $808080,
    $6A240A, $FFFFFF, $C8D0D4, $6A240A, $000000, $FFFFFF,
    $808080, $000000, $808080, $0000FF, $00FF00, $00FFFF,
    $FF0000, $FF00FF, $FFFF00, $C8D0D4);

(* palPetz: tgamepalette = ($FFFFFF,
    $000080, $008000, $008080, $800000, $800080, $808000,
    $C0C0C0, $D8CCC0, $000000, $DDE2E7, $D8DEE3, $D4DADF,
    $D0D6DB, $CCD2D7, $C7CED3, $C3CACF, $BFC6CB, $BBC2C7,
    $B6BEC3, $757575, $6F6F6F, $6A6A6A, $656565, $606060,
    $5B5B5B, $565656, $515151, $4C4C4C, $464646, $424242,
    $3A3A3A, $333333, $2C2C2C, $242424, $1D1D1D, $161616,
    $0E0E0E, $070707, $000000, $96C2DC, $90BBD5, $8AB5CF,
    $85AFC8, $7FA9C2, $7AA2BB, $749CB5, $6F96AE, $6990A8,
    $6389A2, $224187, $203D7F, $1E3977, $1C3570, $1A3168,
    $182D61, $162959, $142552, $12214A, $101D42, $1673B4,
    $136DAF, $1168AA, $0E63A5, $0C5EA1, $09589C, $075397,
    $044E93, $02498E, $004489, $B79EF0, $B299E9, $AD95E3,
    $A891DD, $A38DD6, $9E88D0, $9984CA, $9480C3, $8F7CBD,
    $8B77B7, $0129A8, $0128A4, $01279F, $01269B, $012597,
    $012492, $01238E, $01228A, $012185, $012081, $0C4A6B,
    $0B4465, $0B3E60, $0B395B, $0B3356, $0A2D51, $0A274C,
    $0A2247, $0A1C42, $09163C, $388AA6, $3785A2, $37819E,
    $377D9A, $367896, $367493, $36708F, $356B8B, $356787,
    $356284, $7D7062, $76695D, $706358, $695D53, $63574E,
    $5D5049, $564A44, $50443F, $4A3E3A, $433836, $738E9A,
    $708A96, $6D8793, $6B8490, $68818C, $667E89, $637B86,
    $617882, $5E757F, $5B717C, $57AB55, $47A13C, $179915,
    $368335, $1C7B30, $197910, $176227, $2B5E2F, $145C13,
    $114110, $C3612B, $E34638, $FF3B33, $CE4333, $D71A16,
    $B63C2E, $A91C16, $90422A, $772219, $531911, $FFF0D8,
    $FFE0AC, $FFD699, $FFCA82, $E8B675, $FFC068, $DC9651,
    $CE9C18, $B98B56, $A9891E, $A7EDEB, $90EBEA, $77CCD1,
    $00F4F7, $32E8ED, $0BC4C3, $34C3C3, $17A29F, $439F9F,
    $2E7A6E, $FFFFFF, $E7E4C0, $D5C6AC, $B1A7A7, $A8A0A0,
    $B6A074, $B19983, $B19983, $B09880, $B09880, $ACBEE2,
    $9093D5, $6E76D7, $6773B8, $73779F, $5D6AA2, $586489,
    $4D5798, $42456A, $313C5A, $8C9E72, $808000, $757A42,
    $808000, $607839, $635A3D, $475826, $2B4121, $303912,
    $FFFFFF, $FFFFFF, $D8F6F4, $C2D8E9, $595F2C, $C5F4D3,
    $9FD3C4, $1AC7FF, $9BB8B0, $77B1AF, $8E94A5, $8FA9AC,
    $14A0D7, $087FC6, $466ECA, $618E79, $4D7E99, $808080,
    $2A9B65, $16CB00, $396CA7, $0042FF, $426497, $2A6599,
    $6A34DD, $754429, $B56958, $846B42, $806450, $4A5975,
    $1418FE, $2B5C6E, $39429C, $4232B8, $424488, $7F4455,
    $868C7E, $0C10CF, $141992, $122F33, $0E2811, $29100D,
    $000000, $000000, $000000, $000000, $FFFFFF, $806450,
    $000000, $808080, $0000FF, $00FF00, $00FFFF, $FF0000,
    $FF00FF, $FFFF00, $000000);   *)

  palBabyz: tgamepalette = ($00000000
    , $00000080, $00008000, $00008080, $00800000, $00800080, $00808000
    , $00C0C0C0, $00C0C0C0, $00808000, $001673B4, $0090EBEA, $00356284
    , $008F7CBD, $007D7062, $00C7CED3, $000C4A6B, $00586489, $0012214A
    , $0042588C, $006178BE, $005F73AF, $007E98DA, $00896B90, $00F7C3F6
    , $00C38BC1, $00E255B6, $008D386B, $00B14785, $00702E54, $007A576B
    , $00CD186D, $009B4969, $005D6AA2, $004C5A8C, $007E98C8, $005C7BAF
    , $006982BE, $0000CBFF, $000098C9, $000082AC, $007C97AD, $008AB5CF
    , $0087A5BC, $008EA2C8, $00899EC5, $00778FD7, $006D83A7, $00718CB9
    , $00526AA3, $00000000, $000F0F0F, $001F1F1F, $002F2F2F, $003F3F3F
    , $004F4F4F, $005F5F5F, $006F6F6F, $007F7F7F, $008F8F8F, $009F9F9F
    , $00AFAFAF, $00BFBFBF, $00CFCFCF, $00DFDFDF, $00EFEFEF, $00FFFFFF
    , $006F6DBC, $006B4ABD, $00513F7A, $00864FE5, $004D0978, $00F7A5C0
    , $00D1647B, $0097091C, $004F3437, $00F8929A, $00F10B09, $00705151
    , $008E7070, $008E5453, $00AF7170, $00CD948F, $00AB5950, $00AF908D
    , $00746A69, $004B1A0E, $00763729, $00F4D5CD, $00BE441B, $00994A2D
    , $00AD5734, $00BE6A4A, $00874629, $0099877E, $00CB6B31, $008F6C56
    , $00C8AFA0, $00F8AB57, $00F6D5B0, $00D2C8BD, $00F49118, $00F89828
    , $00D98728, $00B36F12, $00D58117, $00865413, $00B17728, $00F8AC30
    , $00BB9559, $008C6C29, $0064522C, $00736A57, $008A6817, $00F8C83F
    , $00F5ECD3, $00F3BB09, $00D0A009, $00F8D76B, $00C9BF55, $00B6B638
    , $009CAA94, $0034962A, $0011560E, $0029C328, $002CED38, $00D1EDD3
    , $001A9A24, $0048D358, $0066F675, $003CAF4F, $008AE89B, $00256633
    , $00ACF3BA, $004F6D55, $00238F3C, $00387847, $00131C15, $00396143
    , $0072B684, $00388A54, $00287845, $002D3530, $00288852, $004B946B
    , $0041A972, $0058E197, $00286748, $00387859, $0037916A, $004BB287
    , $00287859, $0017AB76, $00138F63, $001FCA91, $00126E50, $0027EFB3
    , $00286458, $00385D58, $00EFF7F6, $0064DFDC, $0008F5F7, $00142F2F
    , $00080909, $004F5050, $00154B4E, $0043E9F4, $0084F2F7, $00166D74
    , $0012B9CC, $008A9495, $00338C99, $0051B2C6, $00316A76, $00518A95
    , $0016758D, $00516C72, $00B6EAF7, $00718B91, $0095AAAF, $00CEEBF4
    , $006BC3E6, $0076D2F8, $006BB5D2, $0093D1EA, $006F797D, $00324852
    , $0079A9BF, $008FBDD1, $00AFC9D5, $006E97AC, $0009A2F6, $00B1D6EB
    , $00184E70, $004D8CB4, $001683CA, $00ADB7BE, $00CBD7E0, $00488EC9
    , $00376A94, $00146AB4, $005899D1, $00173757, $004A9BF3, $004B6E93
    , $00124D91, $00366CAA, $008A98A8, $00334F72, $000860E8, $0037578C
    , $004970AB, $00193669, $002B374D, $004C576B, $00152649, $000B142E
    , $0049578E, $004657F1, $003946CB, $000815E0, $00888AD2, $00090AAC
    , $00080A78, $00080953, $00333589, $004A4AAE, $007577F7, $00A7A7F8
    , $001418FE, $002B5C6E, $00C0C0C0, $004232B8, $00424488, $007F4455
    , $00868C7E, $000C10CF, $00141992, $00122F33, $000E2811, $0029100D
    , $00000000, $00000000, $00800000, $00000000, $00FFFFFF, $00F0FBFF
    , $00A4A0A0, $00808080, $000000FF, $0000FF00, $0000FFFF, $00FF0000
    , $00FF00FF, $00FFFF00, $00800000);
  palOddballz: tgamepalette = ($000000,
    $000080, $008000, $008080, $800000, $800080, $808000,
    $C0C0C0, $C0C0C0, $808000, $FFFFFF, $F8F8F9, $F0F1F2,
    $E8EAEB, $E0E2E5, $D8DBDE, $D0D4D7, $C8CCD1, $C0C5CA,
    $B8BEC3, $999999, $8F8F8F, $858585, $7B7B7B, $717171,
    $676767, $5E5E5E, $545454, $4A4A4A, $404040, $424242,
    $3A3A3A, $333333, $2C2C2C, $242424, $1D1D1D, $161616,
    $0E0E0E, $070707, $000000, $0C4A6B, $0C4466, $0C3E61,
    $0B395C, $0B3357, $0B2D51, $0B284C, $0A2247, $0A1C42,
    $0A173D, $45FDF5, $41F8F2, $3DF2F0, $39EDED, $35E7EA,
    $30E1E8, $2CDCE5, $28D6E3, $24D1E0, $20CBDE, $3E8EF5,
    $3786EF, $307FE9, $2978E3, $2271DD, $1B69D6, $1462D0,
    $0D5BCA, $0654C4, $004CBE, $D1C9FF, $CCC3FF, $C8BCFF,
    $C4B5FF, $C0AFFF, $BCA8FF, $B7A1FF, $B39BFF, $AF94FF,
    $AB8DFF, $0F17C5, $0F17BC, $0F17B3, $0F17AA, $0F17A1,
    $0F1799, $0F1790, $0F1787, $0F177E, $0F1775, $A31CB5,
    $991BAB, $9019A0, $871796, $7D168B, $741481, $6A1277,
    $61116C, $580F62, $4E0D57, $4F7C90, $4C778B, $4A7386,
    $476F82, $456B7D, $426778, $3F6373, $3D5F6E, $3A5B6A,
    $375765, $5C910F, $588B0E, $54840E, $517D0D, $4D770D,
    $49700C, $46690C, $42620B, $3E5C0A, $3B550A, $F73100,
    $F81800, $EF1800, $E71800, $DA1801, $D82900, $CD0F02,
    $B41004, $AA2601, $910D28, $FF9CC6, $FF92BF, $E584AB,
    $E17BA2, $D6759A, $CD7395, $C66B8C, $BB6D8C, $AF6383,
    $9C5577, $77D2FF, $6DC5FF, $63BEFF, $5CB4FF, $55ADF4,
    $4CA8FF, $449BF5, $2A9DF1, $3392E7, $008DE4, $004A92,
    $00428E, $004284, $00397D, $003C73, $00316C, $003161,
    $00295C, $002951, $001358, $A11000, $941000, $931800,
    $890C00, $770900, $731B07, $6B0E00, $5E0E00, $520D00,
    $3E0700, $160100, $001400, $00FF00, $005F0E, $000314,
    $180E17, $008C18, $009418, $001823, $2F2127, $F98F29,
    $2F2E2D, $00712D, $690836, $00163A, $002241, $322A43,
    $5C3547, $393F48, $6D3F55, $655A5F, $904F61, $7F7180,
    $283B8F, $005F8F, $000196, $999999, $001A9C, $004A9C,
    $0851A3, $0049A5, $0052AA, $346DAB, $0B65BA, $0077BC,
    $0006BD, $0051BE, $7EA0BE, $0028C0, $E995C0, $1C73CE,
    $FF9CCE, $FFA5CE, $0031CF, $1155D2, $2F96D2, $0000D6,
    $207CD8, $2C82DA, $0018DB, $003CEC, $00A9EF, $0000F3,
    $0018F3, $00EDFE, $FF00FF, $001DFF, $0042FF, $1AC7FF,
    $800000, $808080, $C0C0C0, $FFFFFF, $000000, $000000,
    $000000, $FFFFFF, $C0C0C0, $C0C0C0, $808080, $800000,
    $FFFFFF, $C0C0C0, $808080, $000000, $FFFFFF, $808080,
    $000000, $808080, $0000FF, $00FF00, $00FFFF, $FF0000,
    $FF00FF, $FFFF00, $C0C0C0);
  {palOddballz: tgamepalette = ($00FFFFFF
    , $00000000, $00008080, $00800000, $00800080, $00008000, $00808000
    , $00C0C0C0, $00000000, $00000000, $00000000, $00F8F8F9, $00F0F1F2
    , $00E8EAEB, $00E0E2E5, $00D8DBDE, $00D0D4D7, $00C8CCD1, $00C0C5CA
    , $00B8BEC3, $00999999, $008F8F8F, $00858585, $007B7B7B, $00717171
    , $00676767, $005E5E5E, $00545454, $004A4A4A, $00404040, $00424242
    , $003A3A3A, $00333333, $002C2C2C, $00242424, $001D1D1D, $00161616
    , $000E0E0E, $00070707, $00000000, $000C4A6B, $000C4466, $000C3E61
    , $000B395C, $000B3357, $000B2D51, $000B284C, $000A2247, $000A1C42
    , $000A173D, $0045FDF5, $0041F8F2, $003DF2F0, $0039EDED, $0035E7EA
    , $0030E1E8, $002CDCE5, $0028D6E3, $0024D1E0, $0020CBDE, $003E8EF5
    , $003786EF, $00307FE9, $002978E3, $002271DD, $001B69D6, $001462D0
    , $000D5BCA, $000654C4, $00004CBE, $00D1C9FF, $00CCC3FF, $00C8BCFF
    , $00C4B5FF, $00C0AFFF, $00BCA8FF, $00B7A1FF, $00B39BFF, $00AF94FF
    , $00AB8DFF, $000F17C5, $000F17BC, $000F17B3, $000F17AA, $000F17A1
    , $000F1799, $000F1790, $000F1787, $000F177E, $000F1775, $00A31CB5
    , $00991BAB, $009019A0, $00871796, $007D168B, $00741481, $006A1277
    , $0061116C, $00580F62, $004E0D57, $004F7C90, $004C778B, $004A7386
    , $00476F82, $00456B7D, $00426778, $003F6373, $003D5F6E, $003A5B6A
    , $00375765, $005C910F, $00588B0E, $0054840E, $00517D0D, $004D770D
    , $0049700C, $0046690C, $0042620B, $003E5C0A, $003B550A, $00F73100
    , $00F81800, $00EF1800, $00E71800, $00DA1801, $00D82900, $00CD0F02
    , $00B41004, $00AA2601, $00910D28, $00FF9CC6, $00FF92BF, $00E584AB
    , $00E17BA2, $00D6759A, $00CD7395, $00C66B8C, $00BB6D8C, $00AF6383
    , $009C5577, $0077D2FF, $006DC5FF, $0063BEFF, $005CB4FF, $0055ADF4
    , $004CA8FF, $00449BF5, $002A9DF1, $003392E7, $00008DE4, $00004A92
    , $0000428E, $00004284, $0000397D, $00003C73, $0000316C, $00003161
    , $0000295C, $00002951, $00001358, $00A11000, $00941000, $00931800
    , $00890C00, $00770900, $00731B07, $006B0E00, $005E0E00, $00520D00
    , $003E0700, $00160100, $00001400, $0000FF00, $00005F0E, $00000314
    , $00180E17, $00008C18, $00009418, $00001823, $002F2127, $00F98F29
    , $002F2E2D, $0000712D, $00690836, $0000163A, $00002241, $00322A43
    , $005C3547, $00393F48, $006D3F55, $00655A5F, $00904F61, $007F7180
    , $00283B8F, $00005F8F, $00000196, $00999999, $00001A9C, $00004A9C
    , $000851A3, $000049A5, $000052AA, $00346DAB, $000B65BA, $000077BC
    , $000006BD, $000051BE, $007EA0BE, $000028C0, $00E995C0, $001C73CE
    , $00FF9CCE, $00FFA5CE, $000031CF, $001155D2, $002F96D2, $000000D6
    , $00207CD8, $002C82DA, $000018DB, $00003CEC, $0000A9EF, $000000F3
    , $000018F3, $0000EDFE, $00FF00FF, $00001DFF, $000042FF, $001AC7FF
    , $00000000, $00000000, $00000000, $00000000, $00000000, $00000000
    , $00000000, $00000000, $00000000, $00000000, $00000000, $00000000
    , $00000000, $00000000, $00000000, $00000000, $00000000, $00F0FBFF
    , $00A4A0A0, $00808080, $000000FF, $0000FF00, $0000FFFF, $00FF0000
    , $00FF00FF, $00FFFF00, $00000000);     }
  palDogz1: tgamepalette = ($000000,
    $000080, $008000, $008080, $800000, $800080, $808000,
    $808080, $C0C0C0, $0000FF, $00FF00, $00FFFF, $FF0000,
    $FF00FF, $FFFF00, $FFFFFF, $C4CCD8, $B2B9C3, $A0A6AE,
    $8E9399, $7C8084, $6B6D70, $299ACF, $268EC0, $2283B0,
    $1F77A0, $1C6B90, $196080, $4493D4, $3784CA, $2A75BF,
    $1D66B4, $1056A9, $03479F, $093FE4, $0838D3, $0632C3,
    $052BB3, $0325A2, $021E92, $174B9C, $15448E, $123D80,
    $103771, $0E3063, $0C2955, $0210AD, $020EA1, $020D95,
    $020B89, $01097D, $010871, $1A2438, $1B2A46, $1D3055,
    $1F3764, $213D73, $224482, $00E600, $00D600, $00C600,
    $00B500, $00A500, $009400, $63B3A9, $59A49A, $4F948C,
    $44857D, $3A766E, $30665F, $08E7E9, $0ED8DC, $13C9CF,
    $18BAC1, $1EACB4, $239DA7, $0000FF, $0000F0, $0000E0,
    $0000D1, $0000C1, $0000B2, $D05AD9, $BE52C6, $AC4BB2,
    $9A439F, $893B8C, $773379, $B38F1A, $A48317, $947715,
    $856A13, $755E11, $66520F, $D7096C, $C0085F, $AA0652,
    $930546, $7C0339, $65022C, $161619, $1F1F23, $28282D,
    $313137, $3A3A42, $43434C, $0DBEA3, $0BAAA7, $0997AC,
    $0783B0, $056FB5, $045CB9, $6D7910, $736910, $785911,
    $7E4912, $833913, $892914, $0033FF, $004BFF, $0064FF,
    $007CFF, $0095FF, $00AEFF, $DB85D6, $D197BE, $C7AAA5,
    $BDBC8D, $B3CE74, $A9E05C, $00106F, $031D78, $072A81,
    $0B378A, $0F4594, $13529D, $DDF7F7, $0000FF, $3300FF,
    $FF00FF, $CC4DFF, $FF4DFF, $CCB3FF, $00FFFF, $220000,
    $4D0000, $800000, $CC0000, $FF0000, $803300, $004D00,
    $806600, $008000, $808000, $00B300, $00FF00, $FFFF00,
    $222209, $00260D, $006C11, $00D211, $CC331A, $FF331A,
    $33661A, $000000, $191919, $323232, $4C4C4C, $656565,
    $7F7F7F, $989898, $B2B2B2, $FFFFFF, $FFFBF8, $FFF7F2,
    $FEF4EC, $FFF0E6, $FFECE0, $FFE9DA, $FFE5D4, $008080,
    $198784, $328F88, $4C968C, $659E90, $7FA594, $98AD99,
    $B2B59D, $C0C0C0, $808000, $800000, $808080, $C0C0C0,
    $FFFFFF, $000000, $000000, $000000, $FFFFFF, $C0C0C0,
    $C0C0C0, $808080, $800000, $FFFFFF, $C0C0C0, $808080,
    $808080, $000000, $C0C0C0, $66CC80, $99CC80, $CCCC80,
    $FFCC80, $00FF80, $33FF80, $66FF80, $99FF80, $CCFF80,
    $FFFF80, $9F9F8E, $991999, $661A99, $0000A2, $3300B3,
    $CC00B3, $FF00B3, $CC33B3, $FF33B3, $CC66B3, $FF66B3,
    $C0C0C0, $0000C4, $FFFFCC, $D5EED5, $6600E6, $9900E6,
    $0033E6, $3333E6, $6633E6, $9933E6, $0066E6, $3366E6,
    $6666E6, $9966E6, $0099E6, $3399E6, $9999E6, $66B3E6,
    $FFB3E6, $00CCE6, $33CCE6, $99CCE6, $33FFE6, $66FFE6,
    $99FFE6, $000000, $000000);

  palCatz1: tgamepalette = ($000000,
    $000080, $008000, $008080, $800000, $800080, $808000,
    $808080, $C0C0C0, $0000FF, $00FF00, $00FFFF, $FF0000,
    $FF00FF, $FFFF00, $FFFFFF, $D40000, $116400, $EAAB02,
    $14B71F, $404040, $A50046, $052C56, $3A7190, $0608DD,
    $8408F2, $05F3FC, $0264FF, $333333, $2F2F2F, $2C2C2C,
    $292929, $252525, $222222, $1F1F1F, $1B1B1B, $181818,
    $151515, $E1E3E1, $DFE0DF, $DCDEDC, $DADBDA, $D8D9D8,
    $D5D6D5, $D3D4D3, $D0D1D0, $CECFCE, $CBCCCB, $767676,
    $727272, $6E6E6E, $6A6A6A, $676767, $636363, $5F5F5F,
    $5B5B5B, $575757, $535353, $D09984, $C38F7C, $B78673,
    $AA7C6B, $9D7363, $90695B, $836053, $76564B, $694D42,
    $5C433A, $6592BF, $628EBA, $608BB6, $5D87B1, $5B83AC,
    $5880A7, $567CA2, $53789E, $517599, $4E7194, $0B5095,
    $0A4E92, $0A4C8F, $0A4B8C, $0A4989, $094785, $094682,
    $09447F, $09427C, $094179, $00FFFF, $00FAFB, $00F4F7,
    $00EEF2, $01E8EE, $01E3E9, $01DDE5, $01D7E0, $02D1DC,
    $02CBD7, $0F70D0, $0F6FCF, $0F6ECD, $0F6DCC, $0F6CCA,
    $0E6CC9, $0E6BC7, $0E6AC6, $0E69C4, $0E68C3, $0B0F8B,
    $0A0E87, $090E83, $090D7F, $080D7A, $080C76, $070C72,
    $070B6E, $060B6A, $050A65, $C8AAFF, $C1A1F9, $BB98F2,
    $B48FEC, $AD85E5, $A67CDF, $9F73D8, $986AD2, $9160CB,
    $8A57C5, $FFFFFF, $525252, $8C8C8C, $A5A5A5, $B5B5B5,
    $BDBDBD, $C6C6C6, $D6D6D6, $DEDEDE, $EFEFEF, $73737B,
    $4A4A52, $292939, $181829, $4242C6, $10108C, $00005A,
    $000073, $000094, $0000B5, $0000C6, $1018B5, $31398C,
    $101873, $8494BD, $39425A, $293963, $637394, $31394A,
    $293142, $424A5A, $394252, $6B8CC6, $5A7BB5, $182131,
    $738CB5, $000000, $191919, $323232, $4C4C4C, $656565,
    $7F7F7F, $989898, $B2B2B2, $FFFFFF, $FFFBF8, $FFF7F2,
    $FEF4EC, $FFF0E6, $FFECE0, $FFE9DA, $FFE5D4, $008080,
    $198784, $328F88, $4C968C, $659E90, $7FA594, $98AD99,
    $B2B59D, $D0DCE0, $808000, $800000, $687C88, $A8B8C0,
    $E0F0F8, $000000, $000000, $000000, $FFFFFF, $A8B8C0,
    $A8B8C0, $647D8A, $800000, $FFFFFF, $A8B8C0, $687C88,
    $687C88, $000000, $C0C0C0, $DEB594, $BD8C63, $4A3121,
    $312118, $CE3900, $6B2108, $C63908, $FF4A08, $9C2900,
    $B53100, $F74200, $942908, $FF5221, $F74A18, $733131,
    $8C3939, $421818, $000000, $000000, $000000, $000000,
    $000000, $000000, $000000, $000000, $000000, $000000,
    $000000, $000000, $000000, $000000, $000000, $000000,
    $000000, $000000, $000000, $000000, $000000, $000000,
    $000000, $000000, $000000, $000000, $000000, $000000,
    $000000, $000000, $000000);

var
  colours: PGamepalette;

function paltostr(pal: tpfpaltype): string;
function pickpalette(pal: TPFPalType): PGamepalette;
procedure reducecolours(orig: tbitmap32; dest: tbitmap; pal: TGamePalette; pmin, pmax: byte; trans: byte);
function colourname(col: tcolor): string;
//procedure reduceto256colours(orig: tbitmap32; dest: tbitmap);

implementation

type tcolrecord = record
    index: byte;
    er, eg, eb: Smallint;
  end;

function colourname(col: tcolor): string;
var r, g, b: byte;
begin
  r := col and $FF;
  g := (col shr 8) and $FF;
  b := (col shr 16) and $FF;

  if abs(r-g)+abs(b-g)<30 then begin //gray
    if r < 10 then result := 'Black' else
      if r > 250 then result := 'White' else
        if r < 100 then result := 'Dark gray' else
          if r > 150 then result := 'Light gray' else
            result := 'Gray';
  end;

  case col and $FFFFFF of
    $000080: result:='Red';
    $008000: result:='Green';
    $008080: result:='Khaki';
    $800000: result:='Dark blue';
  end;
{ $000000, $000080, $008000, $008080, $800000, $800080,
    $808000, $C0C0C0, $C8D0D4, $808040, $DDE2E7, $D8DEE3,
    $D4DADF, $D0D6DB, $CCD2D7, $C7CED3, $C3CACF, $BFC6CB,
    $BBC2C7, $B6BEC3, $757575, $6F6F6F, $6A6A6A, $656565,
    $606060, $5B5B5B, $565656, $515151, $4C4C4C, $464646,
    $424242, $3A3A3A, $333333, $2C2C2C, $242424, $1D1D1D,
    $161616, $0E0E0E, $070707, $000000, $96C2DC, $90BBD5,
    $8AB5CF, $85AFC8, $7FA9C2, $7AA2BB, $749CB5, $6F96AE,
    $6990A8, $6389A2, $224187, $203D7F, $1E3977, $1C3570,
    $1A3168, $182D61, $162959, $142552, $12214A, $101D42,
    $1673B4, $136DAF, $1168AA, $0E63A5, $0C5EA1, $09589C,
    $075397, $044E93, $02498E, $004489, $B79EF0, $B299E9,
    $AD95E3, $A891DD, $A38DD6, $9E88D0, $9984CA, $9480C3,
    $8F7CBD, $8B77B7, $0129A8, $0128A4, $01279F, $01269B,
    $012597, $012492, $01238E, $01228A, $012185, $012081,
    $0C4A6B, $0B4465, $0B3E60, $0B395B, $0B3356, $0A2D51,
    $0A274C, $0A2247, $0A1C42, $09163C, $388AA6, $3785A2,
    $37819E, $377D9A, $367896, $367493, $36708F, $356B8B,
    $356787, $356284, $7D7062, $76695D, $706358, $695D53,
    $63574E, $5D5049, $564A44, $50443F, $4A3E3A, $433836,
    $738E9A, $708A96, $6D8793, $6B8490, $68818C, $667E89,
    $637B86, $617882, $5E757F, $5B717C, $57AB55, $47A13C,
    $179915, $368335, $1C7B30, $197910, $176227, $2B5E2F,
    $145C13, $114110, $C3612B, $E34638, $FF3B33, $CE4333,
    $D71A16, $B63C2E, $A91C16, $90422A, $772219, $531911,
    $FFF0D8, $FFE0AC, $FFD699, $FFCA82, $E8B675, $FFC068,
    $DC9651, $CE9C18, $B98B56, $A9891E, $A7EDEB, $90EBEA,
    $77CCD1, $00F4F7, $32E8ED, $0BC4C3, $34C3C3, $17A29F,
    $439F9F, $2E7A6E, $FFFFFF, $E7E4C0, $D5C6AC, $B1A7A7,
    $A8A0A0, $B6A074, $B19983, $B19983, $B09880, $B09880,
    $ACBEE2, $9093D5, $6E76D7, $6773B8, $73779F, $5D6AA2,
    $586489, $4D5798, $42456A, $313C5A, $8C9E72, $808000,
    $757A42, $808000, $607839, $635A3D, $475826, $2B4121,
    $303912, $FFFFFF, $FFFFFF, $D8F6F4, $C2D8E9, $595F2C,
    $C5F4D3, $9FD3C4, $1AC7FF, $9BB8B0, $77B1AF, $8E94A5,
    $8FA9AC, $14A0D7, $087FC6, $466ECA, $618E79, $4D7E99,
    $808080, $2A9B65, $16CB00, $396CA7, $0042FF, $426497,
    $2A6599, $6A34DD, $754429, $B56958, $846B42, $806450,
    $4A5975, $6A240A, $808080, $C8D0D4, $FFFFFF, $000000,
    $000000, $000000, $FFFFFF, $C8D0D4, $C8D0D4, $808080,
    $6A240A, $FFFFFF, $C8D0D4, $6A240A, $000000, $FFFFFF,
    $808080, $000000, $808080, $0000FF, $00FF00, $00FFFF,
    $FF0000, $FF00FF, $FFFF00, $C8D0D4}

end;

function paltostr(pal: tpfpaltype): string;
begin
  case pal of
    pfpPetz: result := 'Petz 2-5';
    pfpBabyz: result := 'Babyz';
    pfpOddballz: result := 'Oddballz';
    pfpCatz1: result := 'Catz 1';
    pfpDogz1: result := 'Dogz 1';
  else result := 'Unknown palette';
  end;
end;

{procedure reduceto256colours(orig: tbitmap32; dest: tbitmap);
var gif: tgifimage;
begin
  gif := tgifimage.Create;
  try
    dest.assign(orig);
    GIF.ColorReduction := rmQuantize;
    GIF.DitherMode := dmFloydSteinberg;
    gif.assign(dest);
    dest.assign(gif);
  finally
    gif.free;
  end;
end;       }

procedure setpetzpalettetobitmap(bmp: graphics.tbitmap; pal: tgamepalette);
var
  i: integer;
  ColorTable: array[byte] of TRGBQuad;
begin
  for i := 0 to 255 do
    with ColorTable[i] do
    begin
      rgbBlue := (pal[i] and $FF0000) shr 16;
      rgbGreen := (pal[i] and $FF00) shr 8;
      rgbRed := pal[i] and $FF;
      rgbReserved := 0;
    end;

  SetDIBColorTable(bmp.Canvas.Handle, 0, 256, ColorTable);
end;

function max3(i1, i2, i3: integer): integer;
begin
  if i1 > i2 then
    if i1 > i3 then
      result := i1 else
    result := i3 else
    if i2 > i3 then
      result := i2 else
      result := i3;
end;

procedure reducecolours(orig: tbitmap32; dest: tbitmap; pal: TGamePalette; pmin, pmax: byte; trans: byte);
var x, y: integer;
  col: tcolrecord;
  row: pbytearray;
  src: tbitmap32;

  function nearestcolour(col: tcolor32): tcolrecord;
  var t1: byte;
    temperr, err: integer;
    fr, fg, fb, pr, pg, pb: byte;
    //dr, dg, db: integer;
  begin
    result.index := 0;

    Color32ToRGB(col, fr, fg, fb);

    err := maxint;
    for t1 := pmin to pmax do
      if t1 <> trans then begin
        pr := pal[t1] and $FF;
        pg := pal[t1] shr 8 and $FF;
        pb := pal[t1] shr 16 and $FF;

{        dr := abs(pr - fr);
        dg := abs(pg - fg);
        db := abs(pb - fb);
        temperr := dr + dg + db + max3(dr, dg, db);}

        temperr := (pr - fr) * (pr - fr) + (pg - fg) * (pg - fg) + (pb - fb) * (pb - fb);
        if temperr < err then begin
          err := temperr;
          result.index := t1;
          if err = 0 then
            break;
        end;
      end;

    pr := pal[result.index] and $FF; //record RGB of chosen colour from palette
    pg := (pal[result.index] and $FF00) shr 8;
    pb := (pal[result.index] and $FF0000) shr 16;

    result.er := fr - pr; {error is original colour minus the chosen colour}
    result.eg := fg - pg;
    result.eb := fb - pb;
  end;

  function applyerror(col: tcolor32; factor: single; err: tcolrecord): tcolor32;
  var r, g, b: byte;
  begin
    Color32ToRGB(col, r, g, b);

    result := Color32(min(max(r + round(factor * err.er), 0), 255),
      min(max(g + round(factor * err.eg), 0), 255),
      min(max(b + round(factor * err.eb), 0), 255), AlphaComponent(col));
  end;

begin

  dest.pixelformat := pf1bit;
  dest.width := orig.width;
  dest.height := orig.height;
  dest.PixelFormat := pf8bit;
  setpetzpalettetobitmap(dest, pal);

  src := tbitmap32.Create;
  try
    src.assign(orig);
    for y := 0 to src.height - 1 do begin
      row := dest.scanline[y];
      for x := 0 to src.width - 1 do
        if AlphaComponent(orig.pixel[x, y]) < 128 then begin
          row[x] := trans;
        end else begin
          col := nearestcolour(src.pixel[x, y]); // find the nearest colour and compute error
          row[x] := col.index; // set the new pixel colour to the output

          if x + 1 < src.width - 1 then
            src.pixel[x + 1, y] := applyerror(src.Pixel[x + 1, y], 7 / 16, col); //apply error
          if y + 1 < src.height - 1 then begin
            if x - 1 > 0 then
              src.pixel[x - 1, y + 1] := applyerror(src.pixel[x - 1, y + 1], 3 / 16, col);
            src.pixel[x, y + 1] := applyerror(src.pixel[x, y + 1], 5 / 16, col);
            if x + 1 < src.width - 1 then
              src.pixel[x + 1, y + 1] := applyerror(src.pixel[x + 1, y + 1], 1 / 16, col);
          end;
        end;
    end;
  finally
    src.free;
  end;
end;

function pickpalette(pal: TPFPalType): PGamepalette;
begin
  case pal of
    pfpPetz: result := @palpetz;
    pfpBabyz: result := @palbabyz;
    pfpOddballz: result := @paloddballz;
    pfpCatz1: result := @palcatz1;
    pfpDogz1: result := @paldogz1;
  else result := @palpetz;
  end;
end;

end.

