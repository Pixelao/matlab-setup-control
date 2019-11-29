        function T = ITC503_ReadT(obj)
                T=extractAfter(queryITC(obj,'R1'),1);
        end