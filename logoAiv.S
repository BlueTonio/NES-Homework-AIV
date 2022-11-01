.db "NES", $1A, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0

.org $8000

.define PPUCTRL $2000
.define PPUMASK $2001
.define OAMADDR $2003
.define OAMDATA $2004
.define PPUSCROLL $2005
.define PPUADDR $2006
.define PPUDATA $2007
.define OAMDMA $4014

.define JOYPAD1 $4016
.define JOYPAD2 $4017

.define SCROLL_X $00
.define SCROLL_Y $01
.define buttons $02

.define nameTablePos $03
.define tilePos $04
.define indexI $05
.define indexJ $06

start:
    LDA #%10000000
    STA PPUCTRL
    LDA #%00011110
    STA PPUMASK
    
    ; load background palette
    LDA #$3f
    STA PPUADDR
    LDA #0
    STA PPUADDR

    LDA #$19
    STA PPUDATA
    LDA #$05
    STA PPUDATA
    LDA #$28
    STA PPUDATA
    LDA #$0F
    STA PPUDATA

    ; load first sprite palette
    LDA #$3f
    STA PPUADDR
    LDA #$10
    STA PPUADDR

    LDA #$21
    STA PPUDATA
    LDA #$22
    STA PPUDATA
    LDA #$23
    STA PPUDATA
    LDA #$24
    STA PPUDATA
   



    LDA #0
    STA OAMADDR
    LDA #$22
    STA OAMDATA
    LDA #$85
    STA OAMDATA
    LDA #%10000001
    STA OAMDATA
    LDA #$22
    STA OAMDATA


    LDA #$20
    STA nameTablePos 
    LDA #$00
    STA tilePos
    JSR drawImage
    LDA #$24
    STA nameTablePos 
    LDA #$00
    STA tilePos
    JSR drawImage

loop:
    JMP loop


drawImage:
    LDA #%10000100
    STA PPUCTRL
    LDX #$10
    STX indexI
    STX indexJ
loop_Draw_Image_Out:
    LDA nameTablePos
    STA PPUADDR
    LDA tilePos
    STA PPUADDR
    loop_Draw_Image_In:
        LDA tilePos
        STA PPUDATA
        CLC 
        ADC #$10
        STA tilePos
        DEC indexI
        BNE loop_Draw_Image_In
    INC tilePos
    LDX #$10
    STX indexI
    DEC indexJ
    BNE loop_Draw_Image_Out
RTS     




readjoy:
    LDA #$01
    STA JOYPAD1
    STA buttons
    LSR A
    STA JOYPAD1
joyloop:
    LDA JOYPAD1
    LSR A 
    ROL buttons
    BCC joyloop
    RTS

nmi:
    PHA
    JSR readjoy
    PLA


Command_Right:
    LDA buttons
    AND #%00000001
    BEQ Command_Left
    LDA #3
    STA OAMADDR
    LDA SCROLL_X
    CMP #250
    BEQ Border_Limit
    JMP Increase_X
    Increase_X:
    INC SCROLL_X
    STA OAMDATA
Command_Left:
    LDA buttons
    AND #%00000010
    BEQ Command_Down
    LDA #3
    STA OAMADDR
    LDA SCROLL_X
    CMP #0
    BEQ Border_Limit
    JMP Decrement_X
    Decrement_X:
    DEC SCROLL_X
    STA OAMDATA
Command_Down:
    LDA buttons
    AND #%00000100
    BEQ Command_Up
    LDA #0
    STA OAMADDR
    LDA SCROLL_Y
    CMP #225
    BEQ Border_Limit
    JMP Increase_Y
    Increase_Y:
    INC SCROLL_Y
    STA OAMDATA
Command_Up:
    LDA buttons
    AND #%00001000
    BEQ LoadScroll
    LDA #0
    STA OAMADDR
    LDA SCROLL_Y
    CMP #6
    BEQ Border_Limit
    JMP Decrement_Y
    Decrement_Y:
    DEC SCROLL_Y
    STA OAMDATA
LoadScroll:
    LDA SCROLL_X
    STA PPUSCROLL
    LDA SCROLL_Y
    STA PPUSCROLL
    RTI


Border_Limit:
    RTI
irq:
    RTI

.goto $FFFA

.dw nmi
.dw start
.dw irq

;.incbin mario0.chr
.incbin aiv256.chr