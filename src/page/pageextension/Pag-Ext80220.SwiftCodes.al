pageextension 80220 SwiftCodes extends "SWIFT Codes"
{
    Layout
    {
        Addafter(Name)
        {
            field(Banco; CodBanco(Rec."Code"))
            {
                ApplicationArea = All;
                Caption = 'Banco';
                ToolTip = 'Código de Banco';
            }
            field("Nombre Banco"; NombreBanco(CodBanco(Rec."Code")))
            {
                ApplicationArea = All;
                Caption = 'Banco';
                ToolTip = 'Código de Banco';
            }
        }
    }

    Local Procedure CodBanco(CodeSwift: Code[20]): Text
    Begin
        CASE CodeSwift OF
            'BDEPESM1XXX':
                Exit('0003');
            'BANDESSSXXX':
                Exit('0004');
            // 'BSABESBBXXX':
            //     Exit('0008');
            // 'BBVAESMMXXX':
            //     Exit('0010');
            'ALLFESMMXXX':
                Exit('0011');
            'SLBKESBBXXX':
                Exit('0013');
            'CATAESBBXXX':
                Exit('0015');
            'CENTESMM':
                Exit('0016');
            'DEUTESBBXXX':
                Exit('0019');
            'BCIOESMMXXX':
                Exit('0020');
            'BCNDESM1XXX':
                Exit('0021');
            'BALEES22XXX':
                Exit('0024');
            'CRLEESMMXXX':
                Exit('0029');
            'ESPCESMMXXX':
                Exit('0030');
            'ETCHES2GXXX':
                Exit('0031');
            'SABNESMMXXX':
                Exit('0036');
            // 'CAIXESBBXXX':
            //     Exit('0041');
            'BGUIES22XXX':
                Exit('0042');
            'GALEES2GXXX':
                Exit('0046');
            'BSCHESMMXXX':
                Exit('0049');
            'BVADESMMXXX':
                Exit('0057');
            'BNPAESMMXXX':
                Exit('0058');
            'MADRESMMXXX':
                Exit('0059');
            'BMARES2MXXX':
                Exit('0061');
            'BARCESMMXXX':
                Exit('0065');
            // 'PSTRESMMXXX':
            //     Exit('0072');
            'OPENESMMXXX':
                Exit('0073');
            'POPUESMMXXX':
                Exit('0075');
            'BAPUES22XXX':
                Exit('0078');
            'BSABESBBXXX':
                Exit('0081');
            'RENBESMMXXX':
                Exit('0083');
            'NORTESMMXXX':
                Exit('0086');
            'VALEESVVXXX':
                Exit('0093');
            'BVALESMMXXX':
                Exit('0094');
            'AHCRESVVXXX':
                Exit('0099');
            'LOYDESMMXXX':
                Exit('0106');
            'BNLIESM1XXX':
                Exit('0107');
            'SOGEESMMXXX':
                Exit('0108');
            'INBBESM1XXX':
                Exit('0113');
            'OCBAESM1XXX':
                Exit('0121');
            'CITIES2XXXX':
                Exit('0122');
            'BAOFESM1XXX':
                Exit('0125');
            'BKBKESMMXXX':
                Exit('0128');
            'INALESM1XXX':
                Exit('0129');
            'CGDIESMMXXX':
                Exit('0130');
            'BESMESMMXXX':
                Exit('0131');
            'PRNEESM1XXX':
                Exit('0132');
            'MIKBESB1XXX':
                Exit('0133');
            'AREBESMMXXX':
                Exit('0136');
            'BKOAES22XXX':
                Exit('0138');
            'PARBESMXXXX':
                Exit('0144');
            'DEUTESM1XXX':
                Exit('0145');
            'BNPAESMSXXX':
                Exit('0149');
            'CHASESM3XXX':
                Exit('0151');
            'BPLCESMMXXX':
                Exit('0152');
            'BSUIESMMXXX':
                Exit('0154');
            'BRASESMMXXX':
                Exit('0155');
            'ABNAESMMXXX':
                Exit('0156');
            'COBAESMXXXX':
                Exit('0159');
            'BOTKESMXXXX':
                Exit('0160');
            'BKTRESM1XXX':
                Exit('0161');
            'MIDLESMMXXX':
                Exit('0162');
            'GEBAESMMXXX':
                Exit('0167');
            'BBRUESMXXXX':
                Exit('0168');
            'NACNESMMXXX':
                Exit('0169');
            'BBVAESMMXXX':
                Exit('0182');
            'BEDFESM1XXX':
                Exit('0184');
            'BFIVESBBXXX':
                Exit('0186');
            'ALCLESMMXXX':
                Exit('0188');
            'BBPIESMMXXX':
                Exit('0190');
            'WELAESMMXXX':
                Exit('0196');
            'BCOEESMMXXX':
                Exit('0198');
            'PRVBESB1XXX':
                Exit('0200');
            'DECRESM1XXX':
                Exit('0205');
            'PROAESMMXXX':
                Exit('0211');
            'POHIESMMXXX':
                Exit('0216');
            'HLFXESMMXXX':
                Exit('0217');
            'FCEFESM1XXX':
                Exit('0218');
            'BMCEESMMXXX':
                Exit('0219');
            'FIOFESM1XXX':
                Exit('0220');
            'GEECESB1XXX':
                Exit('0223');
            'SCFBESMMXXX':
                Exit('0224');
            'FIEIESM1XXX':
                Exit('0225');
            'UBSWESMMXXX':
                Exit('0226');
            'UNOEESM1XXX':
                Exit('0227');
            'IXIUESM1XXX':
                Exit('0228');
            'POPLESMMXXX':
                Exit('0229');
            'DSBLESMMXXX':
                Exit('0231');
            'INVLESMMXXX':
                Exit('0232');
            'POPIESMMXXX':
                Exit('0233');
            'CCOCESMMXXX':
                Exit('0234');
            'PIESESM1XXX':
                Exit('0235');
            'LOYIESMMXXX':
                Exit('0236');
            'CSURES2CXXX':
                Exit('0237');
            'PSTRESMMXXX':
                Exit('0238');
            'CAGLESMMXXX':
                Exit('0239');
            'TRESES2BXXX':
                Exit('0486');
            'GBMNESMMXXX':
                Exit('0487');
            'BFASESMMXXX':
                Exit('0488');
            'GBCCESMMXXX':
                Exit('0490');
            'ICROESMMXXX':
                Exit('1000');
            'BSUDESM1XXX':
                Exit('1113');
            'SCSIESM1XXX':
                Exit('1116');
            'SCBLESM1XXX':
                Exit('1127');
            'IRVTESM1XXX':
                Exit('1156');
            'ESBFESM1XXX':
                Exit('1164');
            'BNACESM1XXX':
                Exit('1168');
            'COURESB1XXX':
                Exit('1173');
            'HYVEESM1XXX':
                Exit('1182');
            'HANDES21XXX':
                Exit('1191');
            'PKBSES21XXX':
                Exit('1193');
            'AEEVESM1XXX':
                Exit('1196');
            'BILLESB1XXX':
                Exit('1197');
            'CRGEESM1XXX':
                Exit('1199');
            'ABCMESM1XXX':
                Exit('1209');
            'REDEESM1XXX':
                Exit('1210');
            'PNBMESM1XXX':
                Exit('1221');
            'RHRHESM1XXX':
                Exit('1224');
            'BSSAESB1XXX':
                Exit('1227');
            'BOCAES21XXX':
                Exit('1231');
            'BCMAESM1XXX':
                Exit('1233');
            'PRBAESM1XXX':
                Exit('1234');
            'HELAESM1XXX':
                Exit('1236');
            'BIMEESM1XXX':
                Exit('1238');
            'LOFPESB1XXX':
                Exit('1240');
            'STOLESM1XXX':
                Exit('1241');
            'SOLAESB1XXX':
                Exit('1242');
            'BEIVESM1XXX':
                Exit('1245');
            'WAFAESM1XXX':
                Exit('1248');
            'NPBSES21XXX':
                Exit('1249');
            'IHZUES21XXX':
                Exit('1251');
            'AARBESM1XXX':
                Exit('1255');
            // 'BBVAESMMXXX':
            //     Exit('1302');
            'CRCGESB1XXX':
                Exit('1451');
            'NEWGESM1XXX':
                Exit('1454');
            'LLISESM1XXX':
                Exit('1457');
            'PRABESMMXXX':
                Exit('1459');
            'CRESESMMXXX':
                Exit('1460');
            'ASSCESM1XXX':
                Exit('1462');
            'PSABESM1XXX':
                Exit('1463');
            'NFFSESM1XXX':
                Exit('1464');
            'INGDESMMXXX':
                Exit('1465');
            'FRANESM1XXX':
                Exit('1466');
            'EHYPESMXXXX':
                Exit('1467');
            'SHSAESM1XXX':
                Exit('1469');
            'BPIPESM1XXX':
                Exit('1470');
            'UCSSESM1XXX':
                Exit('1472');
            'PRIBESMXXXX':
                Exit('1473');
            'CITIESMXXXX':
                Exit('1474');
            'CCSEESM1XXX':
                Exit('1475');
            'MLIBESM1XXX':
                Exit('1478');
            'NATXESMMXXX':
                Exit('1479');
            'VOWAES21XXX':
                Exit('1480');
            'BOFAES2XXXX':
                Exit('1485');
            'PICTESMMXXX':
                Exit('1488');
            'SELFESMMXXX':
                Exit('1490');
            'TRIOESMMXXX':
                Exit('1491');
            'BCITESMMXXX':
                Exit('1494');
            'ESSIESMMXXX':
                Exit('1497');
            'DPBBESM1XXX':
                Exit('1501');
            'IKBDESM1XXX':
                Exit('1502');
            'ARABESMMXXX':
                Exit('1505');
            'MLCBESM1XXX':
                Exit('1506');
            'EFGBESMMXXX':
                Exit('1522');
            'UBIBESMMXXX':
                Exit('1524');
            'BCDMESMMXXX':
                Exit('1525');
            'KBLXESMMXXX':
                Exit('1534');
            'ICBKESMMXXX':
                Exit('1538');
            'BACAESMMXXX':
                Exit('1544');
            'CECAESMMXXX':
                Exit('2000');
            'CECAESMM1':
                Exit('2010');
            'CESCESBBXXX':
                Exit('2013');
            'CECAESMM17':
                Exit('2017');
            'CECAESMM18':
                Exit('2018');
            'CECAESMM31':
                Exit('2031');
            'CAHMESMMXXX':
                Exit('2038');
            'CECAESMM43':
                Exit('2043');
            'CECAESMM45':
                Exit('2045');
            'CECAESMM48':
                Exit('2048');
            'CECAESMM51':
                Exit('2051');
            'CECAESMM52':
                Exit('2052');
            'CECAESMM056':
                Exit('2056');
            'CECAESMM59':
                Exit('2059');
            'CECAESMM66':
                Exit('2066');
            'CAGLESMMVIG':
                Exit('2080');
            'CECAESMM81':
                Exit('2081');
            'CAZRES2ZXXX':
                Exit('2085');
            'CECAESMM86':
                Exit('2086');
            'BASKES2BXXX':
                Exit('2095');
            'CSPAES2LXXX':
                Exit('2096');
            'CECAESMM99':
                Exit('2099');
            'CAIXESBBXXX':
                Exit('2100');
            'CGGKES22XXX':
                Exit('2101');
            'UCJAES2MXXX':
                Exit('2103');
            'CSSOES2SXXX':
                Exit('2104');
            'CECAESMM15':
                Exit('2105');
            'BBVAESMM17':
                Exit('2107');
            'CSPAES2L18':
                Exit('2108');
            // 'CECAESMM52':
            //     Exit('2404');
            'CECAESMM42':
                Exit('2405');
            'CECAESMM37':
                Exit('2406');
            'CECAESMM69':
                Exit('2408');
            'CANVES2PXXX':
                Exit('2410');
            'CECAESMM16':
                Exit('2411');
            'CECAESMM65':
                Exit('2412');
            // 'CECAESMM18':
            //     Exit('2413');
            // 'CECAESMM99':
            //     Exit('2415');
            // 'CECAESMM66':
            //     Exit('2416');
            // 'CECAESMM31':
            //     Exit('2421');
            // 'CECAESMM43':
            //     Exit('2422');
            // 'CECAESMM81':
            //     Exit('2423');
            // 'CECAESMM51':
            //     Exit('2424');
            'BCOEESMM1':
                Exit('3001');
            'BCOEESMM5':
                Exit('3005');
            'BCOEESMM7':
                Exit('3007');
            'BCOEESMM8':
                Exit('3008');
            'BCOEESMM9':
                Exit('3009');
            'BCOEESMM16':
                Exit('3016');
            'BCOEESMM17':
                Exit('3017');
            'BCOEESMM18':
                Exit('3018');
            'BCOEESMM2':
                Exit('3020');
            'BCOEESMM23':
                Exit('3023');
            'CDENESBBXXX':
                Exit('3025');
            'CCRIES2A29':
                Exit('3029');
            'CLPEES2MXXX':
                Exit('3035');
            'CCRIES2A45':
                Exit('3045');
            'CCRIES2AXXX':
                Exit('3058');
            'BCOEESMM59':
                Exit('3059');
            'BCOEESMM6':
                Exit('3060');
            'BCOEESMM63':
                Exit('3063');
            'BCOEESMM67':
                Exit('3067');
            // 'BCOEESMM7':
            //     Exit('3070');
            'BCOEESMM76':
                Exit('3076');
            // 'BCOEESMM8':
            //     Exit('3080');
            'BCOEESMM81':
                Exit('3081');
            'CCRIES2A82':
                Exit('3082');
            'CVRVES2BXXX':
                Exit('3084');
            'BCOEESMM85':
                Exit('3085');
            'BCOEESMM89':
                Exit('3089');
            'CCRIES2A95':
                Exit('3095');
            'BCOEESMM96':
                Exit('3096');
            'BCOEESMM98':
                Exit('3098');
            'BCOEESMM12':
                Exit('3102');
            'BCOEESMM14':
                Exit('3104');
            'CCRIES2A15':
                Exit('3105');
            'BCOEESMM11':
                Exit('3110');
            'BCOEESMM111':
                Exit('3111');
            'CCRIES2A112':
                Exit('3112');
            'BCOEESMM113':
                Exit('3113');
            'CCRIES2A114':
                Exit('3114');
            'BCOEESMM115':
                Exit('3115');
            'BCOEESMM116':
                Exit('3116');
            'BCOEESMM117':
                Exit('3117');
            'CCRIES2A118':
                Exit('3118');
            'CCRIES2A119':
                Exit('3119');
            'CCRIES2A121':
                Exit('3121');
            'CCRIES2A123':
                Exit('3123');
            'BCOEESMM127':
                Exit('3127');
            'BCOEESMM13':
                Exit('3130');
            'BCOEESMM134':
                Exit('3134');
            'CCRIES2A135':
                Exit('3135');
            'CCRIES2A137':
                Exit('3137');
            'BCOEESMM138':
                Exit('3138');
            // 'BCOEESMM14':
            //     Exit('3140');
            'BCOEESMM144':
                Exit('3144');
            'CCCVESM1XXX':
                Exit('3146');
            'BCOEESMM15':
                Exit('3150');
            'CCRIES2A152':
                Exit('3152');
            'CCRIES2A157':
                Exit('3157');
            'BCOEESMM159':
                Exit('3159');
            'CCRIES2A16':
                Exit('3160');
            'BCOEESMM162':
                Exit('3162');
            'CCRIES2A165':
                Exit('3165');
            'BCOEESMM166':
                Exit('3166');
            'CXAVESB1XXX':
                Exit('3171');
            // 'CCOCESMMXXX':
            //     Exit('3172');
            'BCOEESMM174':
                Exit('3174');
            'BCOEESMM177':
                Exit('3177');
            'CCRIES2A179':
                Exit('3179');
            'CASDESBBXXX':
                Exit('3183');
            'CCRIES2A186':
                Exit('3186');
            'BCOEESMM187':
                Exit('3187');
            'CCRIES2A188':
                Exit('3188');
            'BCOEESMM19':
                Exit('3190');
            'BCOEESMM191':
                Exit('3191');
            'MNTYESMMXXX':
                Exit('6814');
            'CSFAESM1XXX':
                Exit('8233');
            'UCINESMMXXX':
                Exit('8512');
            'ESPBESMMXXX':
                Exit('9000');
            'AHCFESMMXXX':
                Exit('3524');
            'CAPIESMMXXX':
                Exit('3604');
            'CSSOES2SFIN':
                Exit('3656');
            'GVCBESBBETB':
                Exit('3682');
            'IBRCESMMXXX':
                Exit('9096');
            'INSGESMMXXX':
                Exit('3575');
            'IPAYESMMXXX':
                Exit('9020');
            'IVALESMMXXX':
                Exit('3669');
            'LISEESMMXXX':
                Exit('3641');
            'MEFFESBBXXX':
                Exit('9094');
            'MISVESMMXXX':
                Exit('3563');
            'MLCEESMMXXX':
                Exit('3661');
            'RENTESMMXXX':
                Exit('3501');
            'XBCNESBBXXX':
                Exit('9091');
            'XRBVES2BXXX':
                Exit('9092');
            'XRVVESVVXXX':
                Exit('9093');


        END;

        EXIT('');
    end;

    procedure NombreBanco(codebanc: Code[20]): Text
    begin
        case codebanc of
            '0241':
                Exit('A&G BANCO, S.A.');
            '2080':
                Exit('Abanca Corporacion Bancaria, S.A.');
            '8620':
                Exit('Abanca Servicios Financieros E.F.C., S.A.');
            '1535':
                Exit('AKF Bank GmbH & Co Kg, Sucursal en España');
            '0011':
                Exit('Allfunds Bank, S.A.');
            '0200':
                Exit('ANDBANK ESPAÑA BANCA PRIVADA, S.A.');
            '0136':
                Exit('Aresbank, S.A.');
            '3183':
                Exit('Arquia Bank, S.A.');
            '1541':
                Exit('Attijariwafa Bank Europe, Sucursal en España');
            '0061':
                Exit('Banca March, S.A.');
            '1550':
                Exit('Banca Popolare Etica Società Cooperativa per Azioni, Sucursal en España');
            '0078':
                Exit('Banca Pueyo, S.A.');
            '0188':
                Exit('Banco Alcalá, S.A.');
            '0182':
                Exit('Banco Bilbao Vizcaya Argentaria, S.A.');
            '0225':
                Exit('Banco Cetelem, S.A.');
            '0198':
                Exit('Banco Cooperativo Español, S.A.');
            '0091':
                Exit('Banco de Albacete, S.A.');
            '0240':
                Exit('Banco de Crédito Social Cooperativo');
            '0003':
                Exit('Banco de Depósitos, S.A.');
            '9000':
                Exit('BANCO DE ESPAÑA');
            '1569':
                Exit('Banco de Investimento Global SA, Sucursal en España');
            '0169':
                Exit('Banco de la Nación Argentina, Sucursal en España');
            '0081':
                Exit('Banco de Sabadell, S.A.');
            '0184':
                Exit('Banco Europeo de Finanzas, S.A.');
            '0220':
                Exit('BANCO FINANTIA, S.A., SUCURSAL EN ESPAÑA');
            '0232':
                Exit('Banco Inversis, S.A.');
            '0186':
                Exit('Banco Mediolanum, S.A.');
            '0121':
                Exit('Banco Occidental, S.A.');
            '0235':
                Exit('Banco Pichincha España, S.A..');
            '1509':
                Exit('Banco Primus, S.A., Sucursal en España');
            '0049':
                Exit('Banco Santander, S.A.');
            '8843':
                Exit('BANGE CREDIT E.F.C. SA');
            '1574':
                Exit('Bank Julius Baer Europe, S.A, Sucursal en España');
            '0219':
                Exit('Bank of Africa Europe, S.A.');
            '1485':
                Exit('Bank of America Europe DAC, Sucursal en España');
            '1488':
                Exit('BANK PICTET & CIE (EUROPE) AG SUCURSAL EN ESPAÑA');
            '8832':
                Exit('Bankinter Consumer Finance, E.F.C., S.A.');
            '0128':
                Exit('Bankinter, S.A.');
            '1525':
                Exit('Banque Chaabi du Maroc, Sucursal en España');
            '1580':
                Exit('BANQUE J. SAFRA SARASIN (LUXEMBOURG) SA, SUCURSAL EN ESPAÑA');
            '0152':
                Exit('Barclays Bank Ireland PLC, Sucursal en España');
            '1554':
                Exit('BFF Bank, S.P.A. Sucursal en España');
            '6712':
                Exit('BIP&Drive EDE, S.A');
            '1533':
                Exit('BMW Bank GmbH, Sucursal en España');
            '6717':
                Exit('Bnext Electronic Issuer, E.D.E. S.L.');
            '1532':
                Exit('BNP Paribas Factor, Sucursal en España');
            '0167':
                Exit('BNP Paribas Fortis, S.A., N.V., Sucursal en España');
            '1492':
                Exit('BNP Paribas Lease Group S.A. Sucursal en España');
            '0149':
                Exit('BNP Paribas S.A., Sucursal en España');
            '1500':
                Exit('BPCE Lease, Sucursal en España');
            '1576':
                Exit('Bunq B.V., Sucursal en España');
            '8640':
                Exit('CA AUTO BANK, SPA, SUCURSAL EN ESPAÑA');
            '1545':
                Exit('CA Indosuez Wealth (Europe), Sucursal en España');
            '0038':
                Exit('CACEIS Bank Spain, S.A.');
            '1451':
                Exit('Caisse Régionale de Crédit Agricole Mutuel Sud-Méditerranée (Ariège et Pyrénées-Orientales)');
            '1493':
                Exit('Caixa Banco de Investimento, S.A. Sucursal en España');
            '3025':
                Exit('Caixa de Crédit dels Enginyers- Caja de Crédito de los Ingenieros, S. Coop. de Crédito');
            '3159':
                Exit('Caixa Popular-Caixa Rural, S. Coop. de Crédito V.');
            '3045':
                Exit('Caixa Rural Altea, Cooperativa de Crédito Valenciana');
            '3162':
                Exit('Caixa Rural Benicarló, S. Coop. de Credit V.');
            '3117':
                Exit('Caixa Rural D''Algemesí, S. Coop. V. de Crédit');
            '3105':
                Exit('Caixa Rural de Callosa d''en Sarrià, Cooperativa de Crédito Valenciana');
            '3096':
                Exit('Caixa Rural de L''Alcudia, Sociedad Cooperativa Valenciana de  Crédito');
            '3123':
                Exit('Caixa Rural de Turís, Cooperativa de Crédito Valenciana');
            '3070':
                Exit('Caixa Rural Galega, Sociedad Cooperativa de Crédito Limitada Gallega');
            '3111':
                Exit('Caixa Rural La Vall ''San Isidro'', Sociedad Cooperativa de Crédito Valenciana');
            '3166':
                Exit('Caixa Rural Les Coves de Vinromá, S. Coop. de Crédit V.');
            '3160':
                Exit('Caixa Rural Sant Josep de Vilavella, S. Coop. de Crédito V.');
            '3102':
                Exit('Caixa Rural Sant Vicent Ferrer de La Vall D''Uixó, Coop. de Credit V.');
            '3118':
                Exit('Caixa Rural Torrent Cooperativa de Credit Valenciana');
            '3174':
                Exit('Caixa Rural Vinarós, S. Coop. de Credit. V.');
            '8776':
                Exit('Caixabank Payments & Consumer, E.F.C., E.P., S.A.');
            '2100':
                Exit('Caixabank, S.A.');
            '2045':
                Exit('Caja de Ahorros y Monte de Piedad de Ontinyent');
            '3029':
                Exit('Caja de Crédito de Petrel, Caja Rural, Cooperativa de Crédito Valenciana');
            '3035':
                Exit('Caja Laboral Popular Coop. de Crédito');
            '3115':
                Exit('Caja Rural ''Nuestra Madre del Sol'', S. Coop. Andaluza de Crédito');
            '3110':
                Exit('Caja Rural Católico Agraria, S. Coop. de Crédito V.');
            '3005':
                Exit('Caja Rural Central, Sociedad Cooperativa de Crédito');
            '3190':
                Exit('Caja Rural de Albacete, Ciudad Real y Cuenca, Sociedad Cooperativa de Crédito');
            '3150':
                Exit('Caja Rural de Albal, Coop. de Crédito V.');
            '3179':
                Exit('Caja Rural de Alginet, Sociedad Cooperativa Crédito Valenciana');
            '3001':
                Exit('Caja Rural de Almendralejo, Sociedad Cooperativa de Crédito');
            '3191':
                Exit('Caja Rural de Aragón, Sociedad Cooperativa de Crédito');
            '3059':
                Exit('Caja Rural de Asturias, Sociedad Cooperativa de Crédito');
            '3089':
                Exit('Caja Rural de Baena Ntra. Sra. de Guadalupe Sociedad Cooperativa de Crédito Andaluza');
            '3060':
                Exit('Caja Rural de Burgos, Fuentepelayo, Segovia y Castelldans, Sociedad Cooperativa de Crédito');
            '3104':
                Exit('Caja Rural de Cañete de Las Torres Ntra. Sra. del Campo Sociedad Cooperativa Andaluza de Crédito');
            '3127':
                Exit('Caja Rural de Casas Ibáñez, S. Coop. de Crédito de Castilla-La Mancha');
            '3121':
                Exit('Caja Rural de Cheste, Sociedad Cooperativa de Crédito Valenciana');
            '3009':
                Exit('Caja Rural de Extremadura, Sociedad Cooperativa de Crédito');
            '3007':
                Exit('Caja Rural de Gijón, Sociedad Cooperativa Asturiana de Crédito');
            '3023':
                Exit('Caja Rural de Granada, Sociedad Cooperativa de Crédito');
            '3140':
                Exit('Caja Rural de Guissona, Sociedad Cooperativa de Crédito');
            '3067':
                Exit('Caja Rural de Jaén, Barcelona y Madrid, Sociedad Cooperativa de Crédito');
            '3008':
                Exit('Caja Rural de Navarra, S. Coop. de Crédito');
            '3098':
                Exit('Caja Rural de Nueva Carteya,  Sociedad Cooperativa Andaluza de Crédito');
            '3016':
                Exit('Caja Rural de Salamanca, Sociedad Cooperativa de Crédito');
            '3017':
                Exit('Caja Rural de Soria, Sociedad Cooperativa de Crédito');
            '3080':
                Exit('Caja Rural de Teruel, Sociedad Cooperativa de Crédito');
            '3020':
                Exit('Caja Rural de Utrera, Sociedad Cooperativa Andaluza de Crédito');
            '3144':
                Exit('Caja Rural de Villamalea, S. Coop. de Crédito Agrario de Castilla-La Mancha');
            '3152':
                Exit('Caja Rural de Villar, Coop. de Crédito V.');
            '3085':
                Exit('Caja Rural de Zamora, Cooperativa de Crédito');
            '3187':
                Exit('Caja Rural del Sur, S. Coop. de Crédito');
            '3157':
                Exit('Caja Rural La Junquera de Chilches, S. Coop. de Crédito V.');
            '3134':
                Exit('Caja Rural Nuestra Señora de la Esperanza de Onda, S. Coop. de Crédito V.');
            '3018':
                Exit('Caja Rural Regional San Agustín Fuente Álamo Murcia, Sociedad Cooperativa de Crédito');
            '3165':
                Exit('Caja Rural San Isidro de Vilafames S. Coop. de Crédito V.');
            '3119':
                Exit('Caja Rural San Jaime de Alquerías Niño Perdido S. Coop. de Crédito V.');
            '3113':
                Exit('Caja Rural San José de Alcora S. Coop. de Crédito V.');
            '3130':
                Exit('Caja Rural San José de Almassora, S. Coop. de Crédito V.');
            '3112':
                Exit('Caja Rural San José de Burriana, S. Coop. de Crédito V.');
            '3135':
                Exit('Caja Rural San José de Nules S. Coop. de Crédito V.');
            '3095':
                Exit('Caja Rural San Roque de Almenara S. Coop. de Crédito  V.');
            '3058':
                Exit('Cajamar Caja Rural, Sociedad Cooperativa de Crédito');
            '3076':
                Exit('Cajasiete, Caja Rural, Sociedad Cooperativa de Crédito');
            '0237':
                Exit('Cajasur Banco, S.A.');
            '8844':
                Exit('CASTELO CAPITAL EFC SA');
            '4706':
                Exit('Caterpillar Financial Corporación Financiera, S.A., E.F.C.');
            '0234':
                Exit('CBNK BANCO DE COLECTIVOS, S.A.');
            '2000':
                Exit('Cecabank, S.A.');
            '1553':
                Exit('China Construction Bank (Europe), S.A., Sucursal en España');
            '1474':
                Exit('Citibank Europe Plc, Sucursal en España');
            '1499':
                Exit('Claas Financial Services, S.A.S., Sucursal en España');
            '1546':
                Exit('CNH Industrial Capital Europe, S.A.S., Sucursal en España');
            '1543':
                Exit('Cofidis, S.A. Sucursal en España');
            '2056':
                Exit('Colonya - Caixa D''estalvis de Pollensa');
            '0159':
                Exit('Commerzbank Aktiengesellschaft, Sucursal en España');
            '1459':
                Exit('Cooperatieve Rabobank U.A., Sucursal en España');
            '8221':
                Exit('Corporación Hipotecaria Mutual, S.A., E.F.C.');
            '8841':
                Exit('CREDIT AGRICOLE CONSUMER FINANCE SPAIN, EFC, S.A.');
            '0154':
                Exit('Crédit Agricole Corporate and Investment Bank, Sucursal en España');
            '1472':
                Exit('Crédit Agricole Leasing & Factoring, Sucursal en España');
            '1555':
                Exit('Crédit Mutuel Leasing, Sucursal en España');
            '1460':
                Exit('Crédit Suisse Ag, Sucursal en España');
            '0243':
                Exit('Credit Suisse Bank (Europe), S.A.');
            '6716':
                Exit('Currencies Direct Spain, EDE, SL');
            '8842':
                Exit('DAIMLER TRUCK FINANCIAL SERVICES ESPAÑA E.F.C., S.A.U.');
            '1457':
                Exit('De Lage Landen International B.V., Sucursal en España');
            '1548':
                Exit('Dell Bank International Designated Activity Company, Sucursal en España');
            '0145':
                Exit('Deutsche Bank, A.G., Sucursal en España');
            '0019':
                Exit('Deutsche Bank, Sociedad Anónima Española');
            '8826':
                Exit('Deutsche Leasing Iberica, E.F.C.,  S.A.');
            '1501':
                Exit('Deutsche Pfandbriefbank AG, Sucursal en España');
            '0211':
                Exit('EBN Banco de Negocios, S.A.');
            '1473':
                Exit('Edmond de Rothschild (Europe), Sucursal en España');
            '3081':
                Exit('Eurocaja Rural, Sociedad Cooperativa de Crédito');
            '0239':
                Exit('Evo Banco S.A.');
            '0218':
                Exit('FCE Bank Plc Sucursal en España');
            '8308':
                Exit('Financiera Carrión, S.A., E.F.C.');
            '8805':
                Exit('Financiera El Corte Inglés E.F.C., S.A.');
            '8823':
                Exit('Financiera española de crédito a distancia, E.F.C., S.A.');
            '6718':
                Exit('FINPAY Entidad de Dineero Electrónico, S.A');
            //#¡VALOR!	Exit('FONDO NARANJA MONETARIO, FI');
            '8839':
                Exit('GCC Consumo, EFC, S.A');
            '1496':
                Exit('Genefim, Sucursal en España');
            '6702':
                Exit('Global Payment Moneytopay, EDE, SL');
            '1564':
                Exit('Goldman Sachs Bank Europe SE, Sucursal en España');
            '1497':
                Exit('Haitong Bank, S.A., Sucursal en España');
            '1504':
                Exit('Honda Bank GmbH, Sucursal en España');
            '0162':
                Exit('HSBC Continental Europe, Sucursal en España');
            '2085':
                Exit('Ibercaja Banco, S.A.');
            '4832':
                Exit('IBERCAJA SERVICIOS DE FINANCIACIÓN, ESTABLECIMIENTO FINANCIERO DE CRÉDITO, S.A.');
            '1514':
                Exit('IC FINANCIAL SERVICES, SUCURSAL EN ESPAÑA');
            '1538':
                Exit('Industrial and Commercial Bank of China (Europe) S.A., Sucursal en España');
            '1465':
                Exit('Ing Bank, N.V. Sucursal en España');
            '1000':
                Exit('Instituto de Crédito Oficial');
            '1494':
                Exit('Intesa Sanpaolo S.p.A., Sucursal en España');
            '1567':
                Exit('J.P. MORGAN SE, SUCURSAL EN ESPAÑA');
            '1482':
                Exit('John Deere Bank, S.A., Sucursal en España');
            '0151':
                Exit('JPMorgan Chase Bank National Association, Sucursal en España');
            // #¡VALOR!	Exit('KUTXABANK MONETARIO AHORRO, FI');
            '2095':
                Exit('Kutxabank, S.A.');
            '1547':
                Exit('Lombard Odier (Europe), S.A., Sucursal en España');
            '8342':
                Exit('Luzaro E.F.C. S.A');
            '6725':
                Exit('MANGOPAY SA SUCURSAL EN ESPAÑA');
            '1520':
                Exit('Mediobanca, Sucursal en España');
            '4799':
                Exit('Mercedes-Benz Financial Services España E.F.C., S.A.');
            '1552':
                Exit('Mirabaud & Cie (Europe) S.A., Sucursal en España');
            '0244':
                Exit('MIRALTA FINANCE BANK, S.A.');
            '1559':
                Exit('Mizuho Bank Europe N.V., Sucursal en España');
            '6723':
                Exit('MODULR FINANCE B.V., SUCURSAL EN ESPAÑA');
            '6720':
                Exit('Moneycorp Technologies Limited, S.E');
            '0160':
                Exit('MUFG Bank (Europe) N.V., Sucursal en España');
            // #¡VALOR!	Exit('Mutuafondo Dinero, FI');
            '1544':
                Exit('MYINVESTOR BANCO, S.A.');
            '1563':
                Exit('N26 BANK AG, SUCURSAL EN ESPAÑA');
            '1479':
                Exit('Natixis, S.A., Sucursal en España');
            '0133':
                Exit('Nuevo Micro Bank, S.A.');
            '8235':
                Exit('OCCIDENT HIPOTECARIA, EFC S.A');
            '1577':
                Exit('Oddo BHF SCA, Sucursal en España');
            '8814':
                Exit('Oney Servicios Financieros, E.F.C., S.A.');
            '0073':
                Exit('Open Bank, S.A.');
            '1568':
                Exit('Orange Bank, S.A., Sucursal en España');
            '6722':
                Exit('PAGONXT EMONEY EDE, S.L.');
            '6707':
                Exit('Pecunia Cards E.D.E. S.L');
            '6713':
                Exit('PFS Card Services Ireland Limited, S.E');
            '1508':
                Exit('RCI Banque, S.A., Sucursal en España');
            '0083':
                Exit('Renta 4 Banco, S.A.');
            '1583':
                Exit('REVOLUT BANK UAB SUCURSAL EN ESPAÑA');
            '3138':
                Exit('Ruralnostra, Sociedad Cooperativa de Crédito Valenciana');
            '0242':
                Exit('Sabadell Consumer Finance, S.A.');
            '0224':
                Exit('Santander Consumer Finance, S.A.');
            '8906':
                Exit('Santander Factoring y Confirming, S.A., E.F.C.');
            '0036':
                Exit('Santander Investment, S.A.');
            '4797':
                Exit('Santander Lease, S.A. EFC');
            '8845':
                Exit('SANTANDER MAPFRE HIPOTECA INVERSA, E.F.C., SA');
            '8813':
                Exit('Scania Finance Hispania, E.F.C., S.A.');
            '6705':
                Exit('Sefide, E.D.E. S.L.');
            '8795':
                Exit('Servicios Financieros Carrefour, E.F.C., S.A.');
            '8833':
                Exit('SG Equipment Finance Iberia, E.F.C., S.A.');
            '1490':
                Exit('Singular Bank, S.A.');
            '1551':
                Exit('SMBC Bank EU AG, Sucursal en España');
            '8816':
                Exit('Sociedad Conjunta para la Emisión y Gestión de Medios de Pago, E.F.C., S.A');
            '0108':
                Exit('Société Genérale, Sucursal en España');
            '1578':
                Exit('SOLARIS SE, SUCURSAL EN ESPAÑA');
            '8838':
                Exit('STELLANTIS FINANCIAL SERVICES ESPAÑA, E.F.C.,');
            '6724':
                Exit('SWAN IO SUCURSAL EN ESPAÑA');
            '0216':
                Exit('Targobank, S.A.');
            '8836':
                Exit('Telefonica Consumer Finance, EFC, S.A.');
            '1573':
                Exit('The Bank of New York Mellon SA/SV, S.E');
            '1570':
                Exit('The Governor and Company of the Bank of Ireland, Sucursal en España');
            '1487':
                Exit('Toyota Kreditbank GmbH, Sucursal en España');
            '4784':
                Exit('Transolver Finance, E.F.C., S.A.');
            '6721':
                Exit('TREEZOR S.A.S., SUCURSAL EN ESPAÑA');
            '1491':
                Exit('Triodos Bank, N.V., S.E.');
            '0226':
                Exit('UBS Europe SE, Sucursal en España');
            '2103':
                Exit('Unicaja Banco, S.A.');
            '1557':
                Exit('Unicredit, S.p.A., Sucursal en España');
            '8596':
                Exit('Unión Cto. Fin. Mob. e Inm., Credifimo, E.F.C., S.A.');
            '8512':
                Exit('Unión de Créditos Inmobiliarios, S.A., E.F.C.');
            '8769':
                Exit('Unión Financiera Asturiana, S.A., E.F.C.');
            '6719':
                Exit('Unnax Regulatory Services, EDE, SL');
            '6709':
                Exit('Up Aganea EDE, SA');
            '8806':
                Exit('VFS Financial Services Spain E.F.C., S.A.');
            '6715':
                Exit('Viva Payment Services, S.A. S.E.');
            '1480':
                Exit('Volkswagen Bank GmbH, Sucursal en España');
            '1575':
                Exit('Western Union International Bank GMBH, Sucursal en España');
            '0229':
                Exit('Wizink Bank, S.A.');
            '8840':
                Exit('Xfera Consumer Finance, E.F.C. S.A.');
            '1560':
                Exit('Younited, Sucursal en España');
        end;

    end;

}
